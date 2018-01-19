class GeoInformationController < ApplicationController

  def index
    @lat_long_weights = JSON.parse(File.open('lat_long_weights.json').read).reject { |k, _| k.blank? }
  end
end
