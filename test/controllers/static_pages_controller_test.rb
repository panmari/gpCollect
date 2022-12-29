# frozen_string_literal: true
require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  test 'should get about' do
    get :about
    assert_response :success
  end

end
