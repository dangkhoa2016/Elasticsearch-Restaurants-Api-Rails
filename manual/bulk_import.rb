require 'elasticsearch'
require 'json'

class BulkImport
  attr_reader :index_name, :file_path, :config_path

  def initialize(index_name = 'restaurants2', config_path = '', file_path = '')

    if config_path.nil? || config_path.length === 0
      config_path = File.join(File.dirname(__FILE__), 'index.v5.json')
    end

    if file_path.nil? || file_path.length === 0
      file_path = File.join(File.dirname(__FILE__), 'au-final.json')
    end

    @index_name = index_name
    @file_path = file_path
    @config_path = config_path
  end

  def run
    return unless init_index

    restaurants = JSON.parse(File.read(file_path))
    total = 0
    
    restaurants.each_slice(30) do |arr|
      body = arr.map do |r|
        _id = r.delete('restaurantId')
        r.delete('_id')
        # v7
        # [{ index: { _index: index_name, _id: _id.to_s } }, r]
        # v6
        # [{ index: { _index: index_name, _type: '_doc', _id: _id.to_s } }, r]
        # v5
        [{ index: { _index: index_name, _type: 'restaurants', _id: _id.to_s } }, r]
      end.flatten
    
      results = elasticsearch_client.bulk({ refresh: true, body: body })
      unless results['errors']
        total += arr.size
        puts "Done: #{arr.size}, total: #{total}"
      else
        puts "Something wrong with endpoint...#{elasticsearch_client. transport. hosts. inspect}"
        break
      end
    end

    puts "Total: #{total}"
  end

  def init_index
    return true if index_exists

    return unless index_name || config_path || File.exists(config_path)
    
    config = JSON.parse(File.read(config_path))
    result = elasticsearch_client.indices.create(index: index_name, body: config) rescue nil
    !result.nil? && result['acknowledged']
  end
  
  def index_exists
    elasticsearch_client.indices.exists(index: index_name)
  end
  
  private

  def elasticsearch_client
    @elasticsearch_client ||= ::Elasticsearch::Client.new url: elasticsearch_url, log: true, trace: true
  end

  def elasticsearch_url
    ENV['ELASTICSEARCH_URL'] || 'http://localhost:9202'
  end

end