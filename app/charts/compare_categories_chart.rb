class CompareCategoriesChart < RuntimeChart
  def initialize(categories)
    super()

    ## Fill with data
    categories.each do |category|
      data = category.run_day_category_aggregates.map do |agg|
        duration = agg.mean_duration
        [LazyHighCharts::OptionsKeyFilter.date_to_js_code(agg.run_day.date), duration]
      end
      self.series(name: 'Mean for ' + category.name,
                  data: data)
    end
  end
end