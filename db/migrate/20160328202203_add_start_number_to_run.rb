class AddStartNumberToRun < ActiveRecord::Migration
  def change
    add_column :runs, :start_number, :integer
  end
end
