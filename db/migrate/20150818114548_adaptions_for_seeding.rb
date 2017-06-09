class AdaptionsForSeeding < ActiveRecord::Migration[4.2]
  def change
    remove_column :runs, :start, :datetime
    remove_column :categories, :age_max, :integer
    add_column :runners, :club_or_hometown, :string
    add_column :runners, :nationality, :string

    remove_column :runs, :duration, :time
    add_column :runs, :duration, :bigint
  end
end
