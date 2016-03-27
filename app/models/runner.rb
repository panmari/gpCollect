class Runner < ActiveRecord::Base
  # TODO: use run_day.date for ordering, seems to be tough to do since it needs another join.
  has_many :runs, -> { order(run_day_id: :asc) }
  has_many :categories, through: :runs
  has_many :run_days, through: :runs
  has_and_belongs_to_many :merge_runners_requests

  def to_param
    "#{id}-#{first_name.parameterize}-#{last_name.parameterize}"
  end

  def fastest_run
    runs.min_by { |i| i.duration || 0 }
  end

  def mean_run_duration
    # Only query database if runs are not eagerly loaded.
    if runs.loaded?
      # TODO: This will produce incorrect results if duration is nil, don't use runs.size in these cases.
      runs.inject(0) {|sum, r| sum + (r.duration || 0)} / runs.size
    else
      runs.average(:duration) || 0
    end
  end
end
