# frozen_string_literal: true

class RunnerDecorator < Draper::Decorator
  delegate_all
  decorates_association :runs

  def name
    "#{object.first_name} #{object.last_name}"
  end

  def fastest_run_duration
    return '-' if object.fastest_run.nil?

    h.format_duration(object.fastest_run.duration)
  end

  def mean_run_duration
    h.format_duration(object.mean_run_duration)
  end
end
