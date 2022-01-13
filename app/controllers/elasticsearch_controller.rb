class ElasticsearchController < ApplicationController
  DEFAULT_INDEX = 'restaurants2'

  def get_doc
    begin
      render json: elasticsearch_client.get({ index: doc_params[:index] || DEFAULT_INDEX, id: doc_params[:id] })
    rescue Elasticsearch::Transport::Transport::ServerError => e
      render plain: e.message
    end
  end

  def search
    search_data = helper.get_geo_search_params(search_params)
    # puts search_data
    sleep 5 if search_data[:sleep]

    # demo only 80 results
    result = elasticsearch_client.search({
      index: search_data[:index],
      body: { query: search_data[:query], size: 80 }
    })

    render json: result
  end

  private

  def helper
    @helper ||= Helper.new
  end

  def elasticsearch_client
    @elasticsearch_client ||= Elasticsearch::Client.new url: elasticsearch_url, log: true, trace: true
  end

  def elasticsearch_url
    ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'
  end

  def doc_params
    params.permit(:id, :index)
  end

  def search_params
    params.permit(:type, :distance, :sleep, :index,
      location: point_params, top_left: point_params,
      bottom_right: point_params)
  end

  def point_params
    [:lat, :lon, :latitude, :longitude, :lng]
  end

  def page_size
    num = (params["page_size"] || '2').to_i
    if num > 10
      num = 10
    elsif num <= 0
      num = 4
    end

    num
  end

  def page_index
    (params["page_index"] || '1').to_i
  end
end
