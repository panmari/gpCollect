require 'test_helper'

class MergeRunnersRequestsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @first = create(:runner)
    second_attributes = @first.attributes.except('id')
    second_attributes['first_name'] += ' test'
    @second = Runner.create(second_attributes)
    @merge_runners_request = MergeRunnersRequest.new_from([@first, @second])
    @merge_runners_request.save!
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:merge_runners_requests)
  end

  test "should get new" do
    cookies[:remembered_runners] = { @first.id => @first.first_name, @second.id => @second.first_name }.to_json
    get :new
    assert_response :success
  end

  test "should create merge_runners_request" do
    assert_difference('MergeRunnersRequest.count') do
      post :create, merge_runners_request: @merge_runners_request.attributes.except('id')
    end

    assert_redirected_to runners_path
  end

  test "should show merge_runners_request" do
    sign_in @admin
    get :show, id: @merge_runners_request
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @merge_runners_request
    assert_response :success
  end

  test "should update merge_runners_request" do
    sign_in @admin
    patch :update, id: @merge_runners_request, merge_runners_request: @merge_runners_request.attributes.except('id')
    assert_redirected_to merge_runners_request_path(assigns(:merge_runners_request))
  end

  test "should destroy merge_runners_request" do
    sign_in @admin
    assert_difference('MergeRunnersRequest.count', -1) do
      delete :destroy, id: @merge_runners_request
    end

    assert_redirected_to merge_runners_requests_path
  end
end
