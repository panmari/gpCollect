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

# Fixes test routes to include locale scope.
class ActionController::TestCase
  module Behavior
    def process_with_default_locale(action, http_method = 'GET', parameters = nil, session = nil, flash = nil)
      parameters = { :locale => I18n.locale }.merge( parameters || {} ) unless I18n.locale.nil?
      process_without_default_locale(action, http_method, parameters, session, flash)
    end
    alias_method_chain :process, :default_locale
  end
end
