# frozen_string_literal: true

require 'test_helper'
require 'rspec/expectations'
require_relative '../../lib/tasks/geocoder'

class CGeocoderTest < ActionController::TestCase
  include RSpec::Matchers

  TEST_API_KEY = 'some_test_key'

  setup do
    @geocoder = Geocoder.new(TEST_API_KEY,
                             'db/geocoding_data/ignored_prefixes.csv',
                             'db/geocoding_data/non_geocodable_club_or_hometown.csv')
  end

  test 'should create expected url for geocoding API' do
    expect(@geocoder.to_uri('Bern', 'SUI').to_s)
      .to eq("https://maps.googleapis.com/maps/api/geocode/json?address=Bern&key=#{TEST_API_KEY}&language=de&region=ch")
  end
end
