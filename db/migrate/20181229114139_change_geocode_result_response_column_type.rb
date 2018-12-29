class ChangeGeocodeResultResponseColumnType < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up { change_column :geocode_results, :response, 'jsonb USING CAST(response AS jsonb)' }
      dir.down { change_column :geocode_results, :response, 'json USING CAST(response AS json)' }
    end
  end
end
