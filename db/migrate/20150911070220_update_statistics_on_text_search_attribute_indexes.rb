require_relative "20150822142453_add_index_to_runners"
# Keep more statistics on these indexes, so they're not accidentally used and lead to very slow queries.
class UpdateStatisticsOnTextSearchAttributeIndexes < ActiveRecord::Migration[4.2]
  def up
    AddIndexToRunners::TEXT_SEARCH_ATTRIBUTES.each do |attr|
      execute("ALTER TABLE index_runners_on_#{attr} ALTER COLUMN #{attr} SET STATISTICS 1000")
    end
  end

  def down
    AddIndexToRunners::TEXT_SEARCH_ATTRIBUTES.each do |attr|
      execute("ALTER TABLE index_runners_on_#{attr} ALTER COLUMN #{attr} SET STATISTICS 500")
    end
  end

end
