require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  setup do
    @category = create(:category_M30)
  end

  test "find categoy by name" do
    assert_equal Category.find_by_name('M30'), @category
  end
end
