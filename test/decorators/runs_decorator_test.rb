# frozen_string_literal: true
require 'test_helper'

class RunsDecoratorTest < ActionController::TestCase
  setup do
    @run = create(:run).decorate
  end

  test 'Duration should be formatted correctly' do
    assert @run.duration_formatted.match(/^\d{2}:\d{2}:\d{2}\.\d$/), 'Formatted not correctly: ' + @run.duration_formatted
  end
end
