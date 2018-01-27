class GeoInformationController < ApplicationController
  def index
    @lat_lng_weights = (2010..2017).map do |year|
      data_as_array = JSON.parse(File.open("lat_long_weights_#{year}.json").read,
                                 symbolize_names: true)
                          .map { |lat_lng, weight| [lat_lng[:lat], lat_lng[:lng], weight] }
      [year, data_as_array]
    end
  end
end
