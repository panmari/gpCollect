require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  # Add more helper methods to be used by all tests here...

  def setup
    @admin = FactoryGirl.create(:admin)
  end

  def teardown
    Admin.delete_all
  end
end

# TODO: Update test helper to insert locale as default parameter.

# Fixes test routes to include locale scope.
