class UpdateGinIndexes < ActiveRecord::Migration[5.2]
  TEXT_SEARCH_ATTRIBUTES = %w(first_name last_name club_or_hometown)
  def change
    enable_extension :pg_trgm
    enable_extension :unaccent

    reversible do |dir|
      dir.up do
        # Updating unaccent function and redoing indexes using the update answer from
        # http://stackoverflow.com/questions/11005036/does-postgresql-support-accent-insensitive-collations/11007216#11007216

        execute("CREATE OR REPLACE FUNCTION public.immutable_unaccent(regdictionary, text)
                  RETURNS text LANGUAGE c IMMUTABLE STRICT AS
                '$libdir/unaccent', 'unaccent_dict';")
        execute("CREATE OR REPLACE FUNCTION public.f_unaccent(text)
                  RETURNS text LANGUAGE sql IMMUTABLE STRICT AS
                $func$
                SELECT public.immutable_unaccent(regdictionary 'public.unaccent', $1)
                $func$;")
        concatenated_attributes = TEXT_SEARCH_ATTRIBUTES.map{|attr| '"runners"."' + attr + '"'}.join(" || ';' || ")
        execute("CREATE INDEX runners_unaccent_concat_gin_idx ON runners USING gin
                (public.f_unaccent(#{concatenated_attributes}) gin_trgm_ops);")
      end
      dir.down do
        remove_index :runners, name: 'runners_unaccent_concat_gin_idx'
      end
    end
  end
end
