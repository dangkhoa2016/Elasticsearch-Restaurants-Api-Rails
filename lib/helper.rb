class Helper
  def to_elasticsearch_point(point)
    return { lat: nil, lon: nil } unless point.present?

    if point.is_a?(String)
      lat, lon = point.split(",")
    elsif point.is_a?(Array)
      lat, lon = point
    else
      lat = point.fetch(:lat, nil)
      lon = point.fetch(:lon, nil)
      lat = point.fetch(:latitude) unless lat.present?
      lon = point.fetch(:longitude, nil) || point.fetch(:lng, nil) unless lon.present?
    end
  
    lat = lat.to_f
    lon = lon.to_f
    
    lat = nil unless is_latitude(lat)
    lon = nil unless is_longitude(lon)
    
    { lat: lat, lon: lon }
  end

  def is_latitude(num)
    num.is_a?(Numeric) && num.abs <= 90
  end

  def is_longitude(num)
    num.is_a?(Numeric) && num.abs <= 180
  end

  def is_location_empty(point, force_convert = false)
    point = to_elasticsearch_point(point) if force_convert
    point.blank? || !point.is_a?(Hash) || point.fetch(:lat, nil).blank? || point.fetch(:lon, nil).blank?
  end
  
  def param_by_rectange(top_left, bottom_right)
    return { err: 'Missing top left point.' } if is_location_empty(top_left)
    return { err: 'Missing bottom right point.' } if is_location_empty(bottom_right)

    {
      "geo_bounding_box": {
        "location": {
          top_left: top_left,
          bottom_right: bottom_right
        }
      }
    }
  end

  def param_by_circle(distance, location)
    return { err: 'Missing center point.' } if is_location_empty(location)

    {
      "geo_distance": {
        distance: distance,
        location: location
      }
    }
  end

  def get_geo_search_params(search_params)
    if search_params[:type] == 'circle'
      { 
        index: search_params[:index], 
        query: param_by_circle(search_params[:distance],
          to_elasticsearch_point(search_params[:location])),
        sleep: search_params[:sleep].to_i
      }
    else
      {
        index: search_params[:index],
        query: param_by_rectange(to_elasticsearch_point(search_params[:top_left]),
          to_elasticsearch_point(search_params[:bottom_right])),
        sleep: search_params[:sleep].to_i
      }
    end
  end
end
