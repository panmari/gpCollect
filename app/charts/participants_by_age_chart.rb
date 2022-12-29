# frozen_string_literal: true

class ParticipantsByAgeChart < ParticipantsChart
  AGE_BUCKET_SIZE = 20

  def initialize
    super()
    legend(layout: 'horizontal')

    # Only min or max is set. LEAST is used to reject the 'NULL' value.
    # 20 exists both as M20 and MU20 in some years. By always subtracting 1 from
    # age_max, we guarantee that all MU categories (which are all under 20) land
    # in the first bucket.
    agg = RunDay.joins(run_day_category_aggregates: :category)
                .group([:date, "(LEAST(age_min, age_max - 1) / #{AGE_BUCKET_SIZE}) * #{AGE_BUCKET_SIZE}"])
                .order([:date, "least_age_min_age_max_1_#{AGE_BUCKET_SIZE}_all_#{AGE_BUCKET_SIZE}"])
                .sum(:runs_count)
    keyed_by_age_bucket = agg.each_with_object({}) do |row, h|
      key, count = *row
      date, age_bucket = *key
      (h[age_bucket] ||= []) << [date_to_miliseconds(date), count]
    end
    keyed_by_age_bucket.each do |age, data|
      series(data: data,
             name: I18n.t('participants_chart.age_bucket',
                          age_bucket: "#{age}-#{age + AGE_BUCKET_SIZE - 1}"))
    end
  end
end
