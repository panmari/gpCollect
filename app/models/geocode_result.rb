# frozen_string_literal: true

class GeocodeResult < ActiveRecord::Base
  has_many :runners
  before_destroy :remove_from_runners
  scope :failed, -> { where("response ->> 'status' != 'OK'") }
  scope :ok, -> { where("response ->> 'status' = 'OK'") }
  scope :ambiguous, -> { where("JSONB_ARRAY_LENGTH(response -> 'results') > ?", 1) }
  scope :non_political, -> { ok.where.not("response -> 'results' -> 0 -> 'types' ? 'political'") }

  def canton
    component = address_component_for('administrative_area_level_1')
    return nil if component.nil?

    component['long_name']
  end

  def country
    component = address_component_for('country')
    return nil if component.nil?

    component['long_name']
  end

  private

  # Type is a string as defined by the Geocode API, e.g.
  # 'administrative_area_level_1' or 'country'.
  def address_component_for(type)
    return nil if response.nil? || response['results'].empty?

    response['results'].first['address_components'].find do |c|
      c['types'].include?(type)
    end
  end

  def remove_from_runners
    runners.update_all(geocode_result_id: nil)
  end
end
