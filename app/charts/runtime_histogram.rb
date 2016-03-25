class RuntimeHistogram < LazyHighCharts::HighChart
  def initialize()
    super(type: 'column')
    c = Category.find_by(sex: 'M', age_min: 20)
    run_day = RunDay.last
    grouping_factor = 10000
    @data = Run.where(run_day: run_day).where.not(duration: nil).group("duration / #{grouping_factor}").count
    # Sort and bring back to correct range.
    @data = @data.sort_by { |k, _| k }.map {|a| [a[0] * grouping_factor, a[1]]}
    set_options
    # TODO: Map and multiply by 1000
    puts @data.sort_by { |k, _| k }

    series({data: @data})
  end

  private

  def set_options
    self.title(text: nil)
    self.chart(type: 'column')
    self.xAxis(type: 'datetime', # y-axis will be in milliseconds
               dateTimeLabelFormats: {
                   # force all formats to be hour:minute:second
                   second: '%H:%M:%S',
                   minute: '%H:%M:%S',
                   hour: '%H:%M:%S',
                   day: '%H:%M:%S',
                   week: '%H:%M:%S',
                   month: '%H:%M:%S',
                   year: '%H:%M:%S'
               },
               title: { text: I18n.t('runtime_chart.time')}
    )
    self.tooltip(
        useHTML: true,
        #shared: true,
        formatter: "function() {
          return '<b>' + this.series.name +'</b><br/>' +
              Highcharts.dateFormat('%H:%M:%S', new Date(this.x)) + '<br/>' +
              this.y;
        }".js_code
    )
    self.legend(enabled: false)
  end
end