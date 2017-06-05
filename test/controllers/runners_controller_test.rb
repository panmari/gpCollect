require 'test_helper'

class RunnersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @runner = create(:runner_with_runs)
    # Create run aggregates that are needed for show action.
    Category.all.each do |category|
      RunDay.all.each do |run_day|
        # Attributes are computed with hooks.
        RunDayCategoryAggregate.create!(category: category, run_day: run_day)
      end
    end
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show runner" do
    get :show, params: { id: @runner.id }
    assert_response :success
  end
end
