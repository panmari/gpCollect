class AddAlphaFotoIdToRunDay < ActiveRecord::Migration
  def change
    add_column :run_days, :alpha_foto_id, :string
  end
end
