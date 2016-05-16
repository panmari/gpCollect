class CreateIndexForRunDuration < ActiveRecord::Migration
  def change
    add_index :runs, [:run_day_id, :duration], order: {run_day_id: :asc, duration: :asc}
  end
end
