class CreateRunDays < ActiveRecord::Migration[4.2]
  def change
    create_table :organizers do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :routes do |t|
      t.float :length

      t.timestamps null: false
    end

    create_table :run_days do |t|
      t.references :organizer, index: true, foreign_key: true
      t.date :date
      t.string :weather
      t.references :route, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
