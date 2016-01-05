class CompareCategoriesChart < RuntimeChart

  # Valid modes at the time of writing are 'mean' and 'min'
  def initialize(categories, mode)
    super()
    categories = Array.wrap(categories)
    title(text: I18n.t("compare_categories_chart.title.#{mode}"))

    ## Fill with data
    categories.each do |category|
      data = category.run_day_category_aggregates.map do |agg|
        duration = agg.send(:"#{mode}_duration")
        [LazyHighCharts::OptionsKeyFilter.date_to_js_code(agg.run_day.date), duration]
      end
      self.series(name: I18n.t("compare_categories_chart.series.#{mode}", category: category.name),
                  data: data)
    end
  end
end