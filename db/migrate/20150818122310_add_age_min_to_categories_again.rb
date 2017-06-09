class AddAgeMinToCategoriesAgain < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :age_max, :integer
  end
end
