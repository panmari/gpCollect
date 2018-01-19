module GeoInformationHelper

  def lat_long_weights_to_js(array)
    content = @lat_long_weights.map do |lat_long_string, weight|
      lat_long = eval(lat_long_string)
      lat = lat_long['lat']
      lng = lat_long['lng']
      visualization_weight = weight # Math.log(weight)
      if lat and lng and visualization_weight > 0
        "{location: new google.maps.LatLng(#{lat}, #{lng}), weight: #{visualization_weight} }"
      end
    end.compact.join(',').html_safe

    '[' + content + ']'
  end
end
