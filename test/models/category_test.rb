# frozen_string_literal: true
require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test "find categoy by name" do
    @category = create(:category_M30)
    assert_equal Category.find_by_name('M30'), @category
  end

  test "find category by name with age max" do
    @category = create(:category, sex: 'W', age_max: 18)
    assert_equal Category.find_by_name('WU18'), @category
  end

  test "should return correct name for category with age max" do
    @category = create(:category, sex: 'W', age_max: 18)
    assert_equal 'WU18', @category.name
  end
end
