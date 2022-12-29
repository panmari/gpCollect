# frozen_string_literal: true

require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test 'should get index' do
    get :index
    assert_response :success
  end
end
