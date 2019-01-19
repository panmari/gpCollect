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

    @helper = MergeRunnersHelpers.new(true)
  end

  test 'merge runners based on case of club_or_hometown' do
    @hans = create(:hans) do |runner|
      run_day = create(:run_day, date: 1.year.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    create(:hans, club_or_hometown: @hans.club_or_hometown.downcase) do |runner|
      run_day = create(:run_day, date: 2.years.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    assert_difference('Runner.count', -1) do
      @helper.merge_duplicates
    end
    assert_equal 'Bern', Runner.first.club_or_hometown
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
      @helper.merge_duplicates
    end
  end

  test 'dont merge runners based on case if their categories descend' do
    @hans = create(:hans) do |runner|
      run_day = create(:run_day, date: 1.year.ago)
      runner.runs.create(run_day: run_day, category: @category_M20)
    end
    create(:hans, club_or_hometown: @hans.club_or_hometown.downcase) do |runner|
      run_day = create(:run_day, date: 2.years.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    assert_no_difference('Runner.count') do
      @helper.merge_duplicates
    end
  end

  test 'merge runners based on nationality' do
    create(:hans, nationality: nil) do |runner|
      run_day = create(:run_day, date: 0.years.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    create(:hans) do |runner|
      run_day = create(:run_day, date: 1.year.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    create(:hans, nationality: 'DEU') do |runner|
      run_day = create(:run_day, date: 2.years.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    assert_difference('Runner.count', -2) do
      @helper.merge_duplicates
    end
    assert_equal 'SUI', Runner.first.nationality
  end

  test 'merge runners based on umlaut' do
    create(:hans) do |runner|
      run_day = create(:run_day, date: 1.year.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    create(:hans, first_name: 'Häns') do |runner|
      run_day = create(:run_day, date: 2.years.ago)
      runner.runs.create(run_day: run_day, category: @category_M30)
    end
    assert_difference('Runner.count', -1) do
      @helper.merge_duplicates
    end
    assert_equal 'Häns', Runner.first.first_name
  end

  test 'merge runners based on sex' do
    create(:hans, first_name: 'Eric') do |runner|
      run_day = create(:run_day, date: 1.year.ago)
      runner.runs.create(run_day: run_day, category: @category_M20)
    end
    create(:hans, first_name: 'Eric', sex: 'W') do |runner|
      run_day = create(:run_day, date: 2.years.ago)
      runner.runs.create(run_day: run_day, category: @category_W20)
    end
    assert_difference('Runner.count', -1) do
      @helper.merge_duplicates
    end
    assert_equal 'M', Runner.first.sex
  end
end
