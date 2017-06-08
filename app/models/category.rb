class Category < ActiveRecord::Base
  has_many :runs
  has_many :run_day_category_aggregates

  scope :ordered, -> { order(:age_max, :age_min, :sex)}

  MODERN_RUNS_YEAR = 2016
  # All categories that occured since the refresh. Older runs have slightly
  # different categories.
  scope :modern, -> { joins(run_day_category_aggregates: :run_day)
    .where('extract(year from run_days.date) = ?', MODERN_RUNS_YEAR)
    .where('runs_count > ?', 0).references(:run_day_category_aggregates)
  }

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
