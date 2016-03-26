class Category < ActiveRecord::Base
  has_many :runs
  has_many :run_day_category_aggregates

  scope :ordered, -> { order({age_min: :asc, age_max: :asc, sex: :asc})}

  # All categories that occured on the latest run day.
  # TODO: Turn this into something scope-like.
  def self.modern
    RunDayCategoryAggregate.includes(:category).where(run_day: RunDay.last).where('runs_count > 0').map(&:category).flatten
  end

  # Orders by in such a way that lower ages come first (independent of upper or lower bound). Sex is interleaved.
  def self.modern_ordered
    self.modern.sort {|a, b| [a.age_min || 0, a.age_max || 0, a.sex] <=> [b.age_min || 0, b.age_max || 0, b.sex] }
  end

  def name
    sex + if age_max
            'U' + age_max.to_s
          else
            age_min.to_s
          end
  end

end
