class GeoInformationController < ApplicationController
  def index
    @lat_long_weights = JSON.parse(File.open('lat_long_weights_2016.json').read,
                                   symbolize_names: true)
                            .reject { |k, _| k.blank? }
  end
end
