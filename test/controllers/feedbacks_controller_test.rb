# frozen_string_literal: true
require 'test_helper'

class FeedbacksControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @feedback = create(:feedback)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:feedbacks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feedback" do
    assert_difference('Feedback.count') do
      post :create, params: {
        feedback: { email: @feedback.email, ip: @feedback.ip, text: @feedback.text }
      }
    end

    assert_redirected_to '/'
  end

  test "should show feedback" do
    sign_in @admin
    get :show, params: { id: @feedback.id }
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, params: { id: @feedback.id }
    assert_response :success
  end

  test "should update feedback" do
    sign_in @admin
    patch :update, params: {
      id: @feedback.id, 
      feedback: { email: @feedback.email, ip: @feedback.ip, text: @feedback.text }
    }
    assert_redirected_to feedback_path(assigns(:feedback))
  end

  test "should destroy feedback" do
    sign_in @admin
    assert_difference('Feedback.count', -1) do
      delete :destroy, params: { id: @feedback.id }
    end

    assert_redirected_to feedbacks_path
  end
end
