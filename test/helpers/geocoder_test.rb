# frozen_string_literal: true

require 'test_helper'
require 'rspec/expectations'
require_relative '../../lib/tasks/geocoder'

class GeocoderTest < ActionController::TestCase
  include RSpec::Matchers

  TEST_API_KEY = 'some_test_key'

  setup do
    @geocoder = Geocoder.new(TEST_API_KEY,
                             'db/geocoding_data/ignored_prefixes.csv',
                             'db/geocoding_data/non_geocodable_club_or_hometown.csv')
  end

  test 'should create expected url for geocoding API' do
    expect(@geocoder.to_uri('Münsingen bei Bern', 'SUI').to_s)
      .to eq("https://maps.googleapis.com/maps/api/geocode/json?address=M%C3%BCnsingen+bei+Bern&key=#{TEST_API_KEY}&language=de&region=ch")
  end

  test 'should return invalid address for url' do
    expect(@geocoder.valid_address?('memler.de')).to be(false)
  end

  test 'should return invalid address for blacklisted addresses' do
    expect(@geocoder.valid_address?('Kapo')).to be(false)
    expect(@geocoder.valid_address?('Laufteam')).to be(false)
  end

  test 'should return valid address for city' do
    expect(@geocoder.valid_address?('Bern')).to be(true)
    expect(@geocoder.valid_address?('Zürich')).to be(true)
  end
end
