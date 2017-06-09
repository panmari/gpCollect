class AddAlphaFotoIdToRunDay < ActiveRecord::Migration[4.2]
  def change
    add_column :run_days, :alpha_foto_id, :string
  end
end
