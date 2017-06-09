class AddCategoryRefToRun < ActiveRecord::Migration[4.2]
  def change
    add_reference :runs, :category, index: true, foreign_key: true
  end
end
