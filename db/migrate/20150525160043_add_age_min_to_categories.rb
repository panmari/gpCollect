class AddAgeMinToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :age_min, :integer
    add_column :categories, :age_max, :integer
    remove_column :categories, :age, :integer
  end
end
