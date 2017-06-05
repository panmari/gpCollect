require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @category = create(:category)
    categoryW = create(:category, sex: 'W')
    create(:run_day_category_aggregate, category: @category)
    create(:run_day_category_aggregate, category: categoryW)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
    assert_not_nil assigns(:participant_chart)
  end

  test "should show category" do
    get :show, params: { id: @category.name }
    assert_response :success
  end
end
