# frozen_string_literal: true
require 'test_helper'

class GeocodeResultsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @geocode_result = create(:geocode_result)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:geocode_results)
  end

  test "should show geocode_result" do
    sign_in @admin
    get :show, params: { id: @geocode_result.id }
    assert_response :success
  end

  test "should destroy geocode_result" do
    sign_in @admin
    assert_difference('GeocodeResult.count', -1) do
      delete :destroy, params: { id: @geocode_result.id }
    end

    assert_redirected_to geocode_results_url
  end
end
