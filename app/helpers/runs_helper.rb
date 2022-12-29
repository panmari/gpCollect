# frozen_string_literal: true

module RunsHelper
  def format_duration(duration)
    return 'disqualified' if duration.nil?
    hours = duration / 3600 / 1000
    minutes = (duration % (3600 * 1000)) / 60 / 1000
    seconds = (duration % (60 * 1000)).to_f / 1000
    format('%02d:%02d:%04.1f', hours, minutes, seconds)
  end
end
