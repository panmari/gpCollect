class ParticipantsByAgeChart < ParticipantsChart
  AGE_BUCKET_SIZE = 20

  def initialize
    super()
    legend(layout: 'horizontal')

    # Only min or max is set. LEAST is used to reject the 'NULL' value.
    agg = RunDay.joins(run_day_category_aggregates: :category)
                .group([:date, "(LEAST(age_min, age_max) / #{AGE_BUCKET_SIZE}) * #{AGE_BUCKET_SIZE}"])
                .order([:date, "least_age_min_age_max_#{AGE_BUCKET_SIZE}_all_#{AGE_BUCKET_SIZE}"])
                .sum(:runs_count)
    keyed_by_age_bucket = agg.each_with_object({}) do |row, h|
      key, count = *row
      date, age_bucket = *key
      (h[age_bucket] ||= []) << [date_to_miliseconds(date), count]
    end
    keyed_by_age_bucket.each do |age, data|
      series(data: data,
             name: I18n.t('participants_chart.age_bucket',
                          age_bucket: "#{age}-#{age + AGE_BUCKET_SIZE}"))
    end
  end
end
