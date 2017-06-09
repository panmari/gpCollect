class AddUnaccentModule < ActiveRecord::Migration[4.2]
  def up
    # Needs this installed: sudo apt-get install postgresql-contrib
    enable_extension :unaccent
  end
end
