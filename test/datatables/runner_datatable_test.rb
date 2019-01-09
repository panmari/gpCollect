# frozen_string_literal: true

require 'test_helper'
require 'rspec/expectations'

class RunnerDatatableTest < ActionController::TestCase
  include RSpec::Matchers

  setup do
    @hans = create(:hans)
  end

  test 'should find hans' do
    mock_view = Minitest::Mock.new
    def mock_view.fa_icon(_); ''; end
    def mock_view.runner_path(_); ''; end
    def mock_view.remember_runner_path(_); ''; end
    def mock_view.link_to(_,_, _); ''; end
    def mock_view.content_tag(_,_, _); ''; end

    params = ActionController::Parameters.new(search: { value: 'hans' },
                                              columns: {"0"=>{"data"=>"first_name"}})
    dt = RunnerDatatable.new(params, view_context: mock_view)
    assert_equal 1, dt.records_filtered_count
    assert_equal 'Hans', dt.data.first[:first_name]
  end
end
