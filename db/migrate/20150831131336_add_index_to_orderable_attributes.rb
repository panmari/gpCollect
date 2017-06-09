class AddIndexToOrderableAttributes < ActiveRecord::Migration[4.2]
  def change
    add_index :runners, :first_name
    add_index :runners, :club_or_hometown
    add_index :runners, :sex
    add_index :runners, :nationality
    add_index :runners, :runs_count
  end
end
