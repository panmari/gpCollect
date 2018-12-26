# frozen_string_literal: true

class GeocodeResult < ActiveRecord::Base
  has_many :runners
  before_destroy :remove_from_runners
  scope :failed, -> { where("response ->> 'status' != 'OK'") }
  scope :ambiguous, -> { where("JSON_ARRAY_LENGTH(response -> 'results') > ?", 1) }

  def canton
    return nil if response['results'].empty?

    canton_result = response['results'].first['address_components'].find do |c|
      c['types'].include?('administrative_area_level_1')
    end
    return nil if canton_result.nil?

    canton_result['long_name']
  end

  private

  def remove_from_runners
    runners.update_all(geocode_result_id: nil)
  end
end
