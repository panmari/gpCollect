require 'test_helper'

class MergeRunnersRequestsTest < ActiveSupport::TestCase
  include RSpec::Matchers

  setup do
    @category_MU20 = create(:category_MU20)
    @category_W20 = create(:category_W20)
    @category_M20 = create(:category_M20)
    @category_M30 = create(:category_M30)
  end

  test 'should compare categories with age min' do
    expect(MergeRunnersRequestsRunCategoriesValidator.compare_categories(@category_M20, @category_M30)).to eq -1
    expect(MergeRunnersRequestsRunCategoriesValidator.compare_categories(@category_M30, @category_M20)).to eq 1
  end

  test 'should compare categories with age min and age max' do
    expect(MergeRunnersRequestsRunCategoriesValidator.compare_categories(@category_MU20, @category_M20)).to eq -1
    expect(MergeRunnersRequestsRunCategoriesValidator.compare_categories(@category_M20, @category_MU20)).to eq 1
  end

  test 'should compare categories with different sex and different age' do
    expect(MergeRunnersRequestsRunCategoriesValidator.compare_categories(@category_W20, @category_M30)).to eq -1
    expect(MergeRunnersRequestsRunCategoriesValidator.compare_categories(@category_M30, @category_W20)).to eq 1
  end

  test 'should compare categories with different sex and same age as equal' do
    expect(MergeRunnersRequestsRunCategoriesValidator.compare_categories(@category_W20, @category_M20)).to eq 0
    expect(MergeRunnersRequestsRunCategoriesValidator.compare_categories(@category_M20, @category_W20)).to eq 0
  end
end
