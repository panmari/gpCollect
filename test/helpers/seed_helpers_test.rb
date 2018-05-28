require 'test_helper'
require "rspec/expectations"
require_relative '../../db/seed_helpers'

class SeedHelpersTest < ActionController::TestCase
  include RSpec::Matchers
  
  test 'should match the most common variant with the name regexp' do
    matches = SeedHelpers::NAME_REGEXP.match 'Abati, Mauro (SUI)'
    expect(matches[:last_name]).to eq('Abati')
    expect(matches[:first_name]).to eq('Mauro')
    expect(matches[:nationality]).to eq('SUI')
  end

  test 'should match names with composed first names separated by dash with the name regexp' do
    matches = SeedHelpers::NAME_REGEXP.match 'Abegglen, Marie-Thérèse (SUI)'
    expect(matches[:last_name]).to eq('Abegglen')
    expect(matches[:first_name]).to eq('Marie-Thérèse')
    expect(matches[:nationality]).to eq('SUI')
  end

  test 'should match names with composed last names separated by dash with the name regexp' do
    matches = SeedHelpers::NAME_REGEXP.match 'Aegerter-Rüegsegger, Verena (SUI)'
    expect(matches[:last_name]).to eq('Aegerter-Rüegsegger')
    expect(matches[:first_name]).to eq('Verena')
    expect(matches[:nationality]).to eq('SUI')
  end

  test 'should match names with composed first names separated by space with the name regexp' do
    matches = SeedHelpers::NAME_REGEXP.match 'Aeschlimann, Karin Andrea (SUI)'
    expect(matches[:last_name]).to eq('Aeschlimann')
    expect(matches[:first_name]).to eq('Karin Andrea')
    expect(matches[:nationality]).to eq('SUI')
  end

  test 'should match names without nationality' do
    matches = SeedHelpers::NAME_REGEXP.match 'von Allmen-Sarmiento, Teresita'
    expect(matches).to be_truthy
    expect(matches[:last_name]).to eq('von Allmen-Sarmiento')
    expect(matches[:first_name]).to eq('Teresita')
    expect(matches[:nationality]).to be nil
  end

  test 'should not match if only nationality is present' do
    matches = SeedHelpers::NAME_REGEXP.match '(SUI)'
    expect(matches).to be_falsey
  end

  test 'should turn a duration with dot and all values correctly to miliseconds' do
    duration = SeedHelpers::duration_string_to_ms '01:01:01.2'
    expect(duration).to be((1 * 3600 + 1 * 60 + 1) * 1000 + 2 * 100)
  end

  test 'should turn a duration with hours correctly to miliseconds' do
    duration = SeedHelpers::duration_string_to_ms '01:00:00,0'
    expect(duration).to be(3600 * 1000)
  end

  test 'should turn a duration without hours correctly to miliseconds' do
    duration = SeedHelpers::duration_string_to_ms '50:00,0'
    expect(duration).to be(50 * 60 * 1000)
  end

  test 'should turn a duration without hundreds miliseconds correctly to miliseconds' do
    duration = SeedHelpers::duration_string_to_ms '1:14:24'
    expect(duration).to be(((1 * 3600 + 14 * 60 + 24) * 1000).to_i)
  end

end
