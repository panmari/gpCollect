class AddRunCountCacheToRunners < ActiveRecord::Migration[4.2]
  def change
    add_column :runners, :runs_count, :integer, default: 0
  end
end
