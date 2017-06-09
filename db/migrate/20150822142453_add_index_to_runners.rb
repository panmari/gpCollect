class AddIndexToRunners < ActiveRecord::Migration[4.2]
  TEXT_SEARCH_ATTRIBUTES = %w(first_name last_name club_or_hometown)

  def change
    enable_extension :pg_trgm
    TEXT_SEARCH_ATTRIBUTES.each do |attr|
      reversible do |dir|
        dir.up do
          # Create an 'unaccent' function that is immutable and thus can be created an index on.
          # See http://stackoverflow.com/questions/11005036/does-postgresql-support-accent-insensitive-collations/11007216#11007216
          execute "CREATE OR REPLACE FUNCTION f_unaccent(text)
                    RETURNS text AS
                    $func$
                    SELECT unaccent('unaccent', $1)
                    $func$  LANGUAGE sql IMMUTABLE SET search_path = public, pg_temp;"
          execute "CREATE INDEX runners_#{attr}_gin ON runners USING gin(f_unaccent(#{attr}) gin_trgm_ops)"
        end
        dir.down do
          remove_index :runners, name: "runners_#{attr}_gin"
        end
      end
    end
  end
end
