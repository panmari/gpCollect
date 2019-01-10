# frozen_string_literal: true

class CompareCategoriesChart < RuntimeChart
  # Valid modes at the time of writing are 'mean' and 'min'
  def initialize(category, modes = %i[min mean])
    super()

    ## Fill with data
    modes.each do |mode|
      data = category.ordered_run_day_category_aggregates.map do |agg|
        duration = agg.send(:"#{mode}_duration")
        [date_to_miliseconds(agg.run_day.date), duration]
      end
      series(name: I18n.t("compare_categories_chart.series.#{mode}",
                          category: category.name),
             data: data)
    end
  end
end
