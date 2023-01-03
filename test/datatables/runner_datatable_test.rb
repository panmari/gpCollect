# frozen_string_literal: true

require 'test_helper'
require 'rspec/expectations'

class RunnerDatatableTest < ActionController::TestCase
  include RSpec::Matchers

  setup do
    @hans = create(:hans)
  end

  test 'should find hans' do
    params = ActionController::Parameters.new(search: { value: 'hans' },
                                              columns: {'0' => {'data' => 'first_name'}})
    dt = RunnerDatatable.new(params)
    assert_equal 1, dt.records_filtered_count
    assert_equal 'Hans', dt.data.first[:first_name]
  end
end
