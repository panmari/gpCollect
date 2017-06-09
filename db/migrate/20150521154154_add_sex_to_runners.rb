class AddSexToRunners < ActiveRecord::Migration[4.2]
  def change
    add_column :runners, :sex, :string
  end
end
