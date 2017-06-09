class AddStartNumberToRun < ActiveRecord::Migration[4.2]
  def change
    add_column :runs, :start_number, :integer
  end
end
