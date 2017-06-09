class AddIndexToRunner < ActiveRecord::Migration[4.2]
  def change
    add_index :runners, :last_name
  end
end
