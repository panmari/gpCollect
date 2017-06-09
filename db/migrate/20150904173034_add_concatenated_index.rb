require_relative "20150822142453_add_index_to_runners"

class AddConcatenatedIndex < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      dir.up do
        AddIndexToRunners.new.migrate(:down)
        enable_extension :pg_trgm
        # Concatenate all attributes postgresql style, separated by semicolon.
        concatenated_attributes = AddIndexToRunners::TEXT_SEARCH_ATTRIBUTES.map{|attr| '"runners"."' + attr + '"'}.join(" || ';' || ")
        execute("CREATE INDEX runners_unaccent_concat_gin_idx ON runners USING gin
                 (f_unaccent(#{concatenated_attributes}) gin_trgm_ops);")
      end
      dir.down do
        remove_index :runners, name: 'runners_unaccent_concat_gin_idx'
        AddIndexToRunners.new.migrate(:up)
      end
    end
  end
end
