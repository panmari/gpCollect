class ParticipantsChart < LazyHighCharts::HighChart
  def initialize(categories)
    super('graph')
    categories = Array.wrap(categories)
    self.title(text: I18n.t('participiants_chart.title'))
    self.chart(type: 'area')
    self.plot_options(area: {
                          stacking: 'normal'
                      })
    self.legend(layout: 'horizontal')

    x_axis_ticks = RunDay.all.map { |run_day| LazyHighCharts::OptionsKeyFilter.date_to_js_code(run_day.date) }
    self.yAxis(title: { text: I18n.t('participiants_chart.x_axis_label')})
    self.xAxis(type: "datetime",
               tickPositioner: "function() {
                 var ticks = [#{generate_json_from_array(x_axis_ticks)}];
                    //dates.info defines what to show in labels
                    //apparently dateTimeLabelFormats is always ignored when specifying tickPosistioner
                    ticks.info = {
                   unitName: 'year', //unitName: 'day',
                       higherRanks: {} // Omitting this would break things
                    };
                    return ticks;
                }".js_code)

    ## Fill with data
    categories.each do |category|
      data = category.run_day_category_aggregates.map do |agg|
        count = agg.runs_count
        [LazyHighCharts::OptionsKeyFilter.date_to_js_code(agg.run_day.date), count]
      end
      self.series(name: I18n.t('participiants_chart.category_label_prefix', category: category.name),
                  data: data)
    end
  end
end