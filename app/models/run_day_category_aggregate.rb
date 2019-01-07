# frozen_string_literal: true

# Represents an aggregate over all runs of a given day and category.
# Used for caching the expensive aggregate queries.
class RunDayCategoryAggregate < ActiveRecord::Base
  self.primary_keys = :run_day_id, :category_id
  belongs_to :run_day
  belongs_to :category
  has_many :runs, class_name: 'Run', foreign_key: %i[run_day_id category_id]

  before_save :update_aggregate_attributes

  def update_aggregate_attributes
    # self.runs somehow does not work until record is saved.
    # Doing multiple aggregations at once is only possible with 'pluck'.
    res = Run.where(run_day: run_day, category: category)
             .pluck(Arel.sql('AVG(duration), MIN(duration), COUNT(*)')).first
    self.mean_duration, self.min_duration, self.runs_count = *res
  end
end
