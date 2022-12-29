# frozen_string_literal: true

class Runner < ActiveRecord::Base
  has_many :runs
  has_many :categories, through: :runs
  has_many :run_days, through: :runs
  has_and_belongs_to_many :merge_runners_requests
  belongs_to :geocode_result, optional: true

  def to_param
    "#{id}-#{first_name.parameterize}-#{last_name.parameterize}"
  end

  def fastest_run
    runs.min_by { |i| i.duration || Float::INFINITY }
  end

  def mean_run_duration
    # Only query database if runs are not eagerly loaded.
    if runs.loaded?
      valid_runs_count = runs.reject { |r| r.duration.nil? }.size
      if valid_runs_count == 0
        nil
      else
        runs.inject(0) { |sum, r| sum + (r.duration || 0) } / valid_runs_count
      end
    else
      runs.average(:duration)
    end
  end
end
