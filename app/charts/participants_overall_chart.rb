# frozen_string_literal: true

class ParticipantsOverallChart < ParticipantsChart
  def initialize
    super()
    legend(enabled: false)

    agg = RunDay.joins(run_day_category_aggregates: :category)
                .group(:date)
                .order(:date)
                .sum(:runs_count)
    series(data: agg.map { |date, count| [date_to_miliseconds(date), count] },
           name: I18n.t('participants_chart.participants'))
  end
end
