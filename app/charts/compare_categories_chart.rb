class CompareCategoriesChart < RuntimeChart
  def initialize(categories, mode)
    super()
    categories = Array.wrap(categories)
    title(text: "#{mode.titleize} time per category")

    ## Fill with data
    categories.each do |category|
      data = category.run_day_category_aggregates.map do |agg|
        duration = agg.send(:"#{mode}_duration")
        [LazyHighCharts::OptionsKeyFilter.date_to_js_code(agg.run_day.date), duration]
      end
      self.series(name: "#{mode} for #{category.name}",
                  data: data)
    end
  end
end