class CreateRunDayCategoryAggregates < ActiveRecord::Migration[4.2]
  def change
    create_table :run_day_category_aggregates do |t|
      t.integer :category_id, null: false
      t.integer :run_day_id, null: false
      t.integer :mean_duration
      t.integer :runs_count
      t.timestamps null: false
    end
    add_index :run_day_category_aggregates, [:run_day_id, :category_id]
  end
end
