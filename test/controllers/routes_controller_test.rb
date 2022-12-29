# frozen_string_literal: true
require 'test_helper'

class RoutesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @route = create(:route)
  end

  test 'should show route' do
    get :show, params: { id: @route.id }
    assert_response :success
  end
end
