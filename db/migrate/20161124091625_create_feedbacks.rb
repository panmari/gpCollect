class CreateFeedbacks < ActiveRecord::Migration[4.2]
  def change
    create_table :feedbacks do |t|
      t.text :text
      t.string :email
      t.string :ip

      t.timestamps null: false
    end
  end
end
