# frozen_string_literal: true

require 'test_helper'

class GeocodeResultTest < ActiveSupport::TestCase
  setup do
    @runner = create(:runner_with_runs)
  end

  test 'should remove association but not destroy runner' do
    assert_difference('GeocodeResult.count', -1) do
      @runner.geocode_result.destroy
    end
    runner = Runner.find(@runner.id)
    assert_not_nil runner
    assert_nil runner.geocode_result_id
  end
end
