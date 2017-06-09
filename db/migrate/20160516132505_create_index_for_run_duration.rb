class CreateIndexForRunDuration < ActiveRecord::Migration[4.2]
  def change
    add_index :runs, [:run_day_id, :duration], order: {run_day_id: :asc, duration: :asc}
  end
end
