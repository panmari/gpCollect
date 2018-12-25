class CreateGeocodeResults < ActiveRecord::Migration[5.2]
  def change
    create_table :geocode_results do |t|
      t.string :address
      t.json :response

      t.timestamps
    end

    add_reference :runners, :geocode_result, index: true, foreign_key: true
  end
end
