# frozen_string_literal: true
require 'test_helper'

class RunsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @run = create(:run)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:runs)
  end

  test "should show run" do
    get :show, params: { id: @run.id }
    assert_response :success
  end
end
