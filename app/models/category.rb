class Category < ActiveRecord::Base
  has_many :runs
  has_many :run_day_category_aggregates

  scope :ordered, -> { order({age_min: :asc, age_max: :asc, sex: :asc})}

  # All categories that occured on the latest run day.
  # TODO: Turn this into something scope-like.
  def self.modern(includes=[])
    RunDayCategoryAggregate.includes(category: includes).where(run_day: RunDay.last).where('runs_count > 0').map(&:category).flatten
  end

  # Orders by in such a way that lower ages come first (independent of upper or lower bound). Sex is interleaved.
  def self.modern_ordered(includes=[])
    self.modern(includes).sort {|a, b| [a.age_min || 0, a.age_max || 0, a.sex] <=> [b.age_min || 0, b.age_max || 0, b.sex] }
  end

  def name
    sex + if age_max
            'U' + age_max.to_s
          else
            age_min.to_s
          end
  end

  # TODO: Maybe add index for this way of retrieval
  def self.find_by_name(name)
    sex = name[0]
    if name[1] == 'U'
      age_max = name[2..-1].to_i
      find_by!(sex: sex, age_max: age_max)
    else
      age_min = name[1..-1].to_i
      find_by!(sex: sex, age_min: age_min)
    end
  end

  def to_param
    name
  end

end
