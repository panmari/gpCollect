# frozen_string_literal: true

require 'test_helper'
require 'rspec/expectations'
require_relative '../../db/merge_runners_helpers'

class MergeRunnersHelpersTest < ActionController::TestCase
  include RSpec::Matchers

  setup do
    @category_W20 = create(:category_W20)
    @category_M20 = create(:category_M20)
    @category_M30 = create(:category_M30)
  end

  test 'should compare categories with same sex' do
    expect(MergeRunnersHelpers.compare_categories(@category_M20, @category_M30)).to eq -1
    expect(MergeRunnersHelpers.compare_categories(@category_M30, @category_M20)).to eq 1
  end

  test 'should compare categories with different sex' do
    expect(MergeRunnersHelpers.compare_categories(@category_W20, @category_M30)).to eq -1
    expect(MergeRunnersHelpers.compare_categories(@category_M30, @category_W20)).to eq 1
  end

  test 'should compare categories with different sex and same age' do
    expect(MergeRunnersHelpers.compare_categories(@category_W20, @category_M20)).to eq 1
    expect(MergeRunnersHelpers.compare_categories(@category_M20, @category_W20)).to eq -1
  end

  test 'merge runners based on case' do
    @hans = create(:hans) do |runner|
      run_day = create(:run_day, date: 1.year.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    create(:hans, club_or_hometown: @hans.club_or_hometown.downcase) do |runner|
      run_day = create(:run_day, date: 2.years.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    assert_difference('Runner.count', -1) do
      MergeRunnersHelpers.merge_duplicates
    end
  end

  test 'dont merge runners based on case if they have run on same day' do
    run_day = create(:run_day_1y_ago)
    @hans = create(:hans) do |runner|
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    create(:hans, club_or_hometown: @hans.club_or_hometown.downcase) do |runner|
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    assert_no_difference('Runner.count') do
      MergeRunnersHelpers.merge_duplicates
    end
  end

end
