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
      post :create, feedback: { email: @feedback.email, ip: @feedback.ip, text: @feedback.text }
    end

    assert_redirected_to '/'
  end

  test "should show feedback" do
    sign_in @admin
    get :show, id: @feedback
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @feedback
    assert_response :success
  end

  test "should update feedback" do
    sign_in @admin
    patch :update, id: @feedback, feedback: { email: @feedback.email, ip: @feedback.ip, text: @feedback.text }
    assert_redirected_to feedback_path(assigns(:feedback))
  end

  test "should destroy feedback" do
    sign_in @admin
    assert_difference('Feedback.count', -1) do
      delete :destroy, id: @feedback
    end

    assert_redirected_to feedbacks_path
  end
end
