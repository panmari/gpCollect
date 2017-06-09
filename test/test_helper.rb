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
# See https://stackoverflow.com/questions/1987354
class ActionController::TestCase
  module Behavior
    module LocaleParameter
      def process(action, params: {}, **args)
        params[:locale] = I18n.locale
        super(action, params: params, **args)
      end
    end
  end
  prepend Behavior::LocaleParameter
end
