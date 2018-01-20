module GeoInformationHelper

  def lat_long_weights_to_js(array)
    content = @lat_long_weights.map do |lat_lng, weight|
      visualization_weight = weight # Math.log(weight)
      if visualization_weight > 0
        "{location: new google.maps.LatLng(#{lat_lng[:lat]}, #{lat_lng[:lng]}), weight: #{visualization_weight} }"
      end
    end.compact.join(',').html_safe

    '[' + content + ']'
  end
end
