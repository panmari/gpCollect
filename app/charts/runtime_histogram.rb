class RuntimeHistogram < LazyHighCharts::HighChart
  def initialize(category=nil)
    super(type: 'column')
    @category = category
    # TODO: Maybe don't aggregate over run days.
    # run_day = RunDay.last
    # TODO: Try other grouping factors.
    grouping_factor = 30000
    runs = if @category
             Run.where(category: @category)
           else
             Run.all
           end
    @data = runs.where.not(duration: nil).group("duration / #{grouping_factor}").count
    # Sort and bring back to correct range.
    @data = @data.sort_by { |k, _| k }.map {|a| [a[0] * grouping_factor, a[1]]}

    set_options
    series({data: @data})
  end

  private

  def set_options
    title_text = if @category
                   'Histogram of run times for category ' + @category.name
                 else
                   'Histogram of run times over all categories'
                 end
    self.title(text: title_text)
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
          return Highcharts.dateFormat('%H:%M:%S', new Date(this.x)) + '<br/>' +
                 this.y;
        }".js_code
    )
    self.legend(enabled: false)
  end
end