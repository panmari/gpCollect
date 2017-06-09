class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories do |t|
      t.string :sex
      t.integer :age

      t.timestamps null: false
    end
  end
end
