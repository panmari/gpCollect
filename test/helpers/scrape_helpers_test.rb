# frozen_string_literal: true

require 'test_helper'
require 'rspec/expectations'
require_relative '../../lib/tasks/scrape_helpers'

class ScrapeHelpersTest < ActionController::TestCase
  include RSpec::Matchers

  test 'should match the most common variant with the name location regexp ' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '20. Volkmer Margrit'
    expect(matches[:rank_category]).to eq('20')
    expect(matches[:name]).to eq('Volkmer Margrit')
    expect(matches[:location]).to be_nil
  end

  test 'should match the variant with location with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '2. Voegeli Stephan, Bolligen'
    expect(matches[:rank_category]).to eq('2')
    expect(matches[:name]).to eq('Voegeli Stephan')
    expect(matches[:location]).to eq('Bolligen')
  end

  test 'should match the variant with last names with spaces with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '1171. Van Der Lingen Patrick'
    expect(matches[:rank_category]).to eq('1171')
    expect(matches[:name]).to eq('Van Der Lingen Patrick')
    expect(matches[:location]).to be_nil
  end

  test 'should match the variant with last names with spaces and location with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '1171. Van Der Lingen Patrick, Bern'
    expect(matches[:rank_category]).to eq('1171')
    expect(matches[:name]).to eq('Van Der Lingen Patrick')
    expect(matches[:location]).to eq('Bern')
  end

  test 'should match the variant with canton  with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '132. Aebi Eugen, Lengnau BE'
    expect(matches[:rank_category]).to eq('132')
    expect(matches[:name]).to eq('Aebi Eugen')
    expect(matches[:location]).to eq('Lengnau BE')
  end

  test 'should match the variant with large string  with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '1098. Aeschlimann Toni, Ostermundige 58 Ascom 4'
    expect(matches[:rank_category]).to eq('1098')
    expect(matches[:name]).to eq('Aeschlimann Toni')
    expect(matches[:location]).to eq('Ostermundige 58 Ascom 4')
  end

  test 'should match with the run type regexp' do
    matches = ScrapeHelpers::RUN_TYPE_OVERALL_RANK_REGEXP.match('GF/361.')
    expect(matches).to_not be_nil
  end

  test 'should spltest names with two strings into last_name and first_name' do
    last_name, first_name = ScrapeHelpers.split_name('Meier Helen')
    expect(first_name).to eq('Helen')
    expect(last_name).to eq('Meier')
  end

  test 'should spltest names with last_name = "van/von der"  ' do
    last_name, first_name = ScrapeHelpers.split_name('von der Heide Helen')
    expect(first_name).to eq('Helen')
    expect(last_name).to eq('von der Heide')

    last_name, first_name = ScrapeHelpers.split_name('Van der Sluis Jan')
    expect(first_name).to eq('Jan')
    expect(last_name).to eq('Van der Sluis')
  end

  test 'should spltest names with last_name = "van/von/di/de/... "  ' do
    last_name, first_name = ScrapeHelpers.split_name('van Empden Carsten')
    expect(first_name).to eq('Carsten')
    expect(last_name).to eq('van Empden')

    last_name, first_name = ScrapeHelpers.split_name('von Niederhäusern Marianne')
    expect(first_name).to eq('Marianne')
    expect(last_name).to eq('von Niederhäusern')
  end

  test 'should spltest names with more than one last_name and/or first_name in the middle  ' do
    last_name, first_name = ScrapeHelpers.split_name('Aridi Rudolf Ameline')
    expect(first_name).to eq('Rudolf Ameline') # in this case, test doesn't work correcty
    expect(last_name).to eq('Aridi')

    last_name, first_name = ScrapeHelpers.split_name('Alder Pascal Janik')
    expect(first_name).to eq('Pascal Janik')
    expect(last_name).to eq('Alder')
  end

  test 'should spltest names with van der only if there is still a first name left.' do
    last_name, first_name = ScrapeHelpers.split_name('Van Der Lee')
    expect(first_name).to eq('Lee')
    expect(last_name).to eq('Van Der')
  end
end
