class CreateRuns < ActiveRecord::Migration[4.2]
  def change
    create_table :runs do |t|
      t.datetime :start
      t.time :duration
      t.references :runner, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
