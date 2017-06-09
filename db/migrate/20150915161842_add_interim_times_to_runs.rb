class AddInterimTimesToRuns < ActiveRecord::Migration[4.2]
  def change
    add_column :runs, :interim_times, :integer, array: true
  end
end
