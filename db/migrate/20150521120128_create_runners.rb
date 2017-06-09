class CreateRunners < ActiveRecord::Migration[4.2]
  def change
    create_table :runners do |t|
      t.string :first_name
      t.string :last_name
      t.date :birth_date

      t.timestamps null: false
    end
  end
end
