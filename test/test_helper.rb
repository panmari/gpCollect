require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  # Add more helper methods to be used by all tests here...

  def setup
    @admin = FactoryBot.create(:admin)
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
      def process_with_kwargs(http_method, action, *args)
        if kwarg_request?(args)
          args.first.merge!(method: http_method)
          args[0] = args.first.deep_merge(params: {locale: I18n.locale })
          process(action, *args)
        else
          # Different version for calling without arguments.
          args = [{method: http_method, params: {locale: I18n.locale }}]
          process(action, *args)
        end
      end
    end
  end
  prepend Behavior::LocaleParameter
end
