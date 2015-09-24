class ParticipantsChart < LazyHighCharts::HighChart
  def initialize(categories)
    super('graph')
    categories = Array.wrap(categories)
    self.title(text: 'Number of participants per category')
    self.chart(type: 'area')
    self.plot_options(area: {
                          stacking: 'normal'
                      })
    self.legend(layout: 'horizontal')

    x_axis_ticks = RunDay.all.map { |run_day| LazyHighCharts::OptionsKeyFilter.date_to_js_code(run_day.date) }
    self.yAxis(title: { text: 'Number participants' })
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
      self.series(name: 'Participants in category ' + category.name,
                  data: data)
    end
  end
end