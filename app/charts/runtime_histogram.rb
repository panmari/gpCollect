class RuntimeHistogram < LazyHighCharts::HighChart
  def initialize(options={})
    super(type: 'column')
    @category = options.fetch(:category, nil)
    @runner_constraint = options.fetch(:runner_constraint, nil)
    # A groupping factor 30000 will lead to buckets of size 30 seconds.
    @grouping_factor = if @runner_constraint
                         120000
                       else
                         30000
                       end
    runs = if @category
             Run.where(category: @category)
           else
             Run.all
           end
    unless @runner_constraint.blank?
      runs = runs.includes(:runner).where(runners: @runner_constraint)
    end
    @data = runs.where.not(duration: nil).group("duration / #{@grouping_factor}").count
    # Sort and bring back to correct range.
    @data = @data.sort_by { |k, _| k }.map { |a| [a[0] * @grouping_factor, a[1]] }

    set_options
    series({data: @data})
  end

  private

  def set_options
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
               title: {text: I18n.t('runtime_chart.time')}
    )
    self.tooltip(
        useHTML: true,
        #shared: true,
        formatter: "function() {
          return '<b>#{I18n.t('runtime_chart.time')}: </b>' +
                 Highcharts.dateFormat('%H:%M:%S', new Date(this.x)) +
                 ' - ' +
                 Highcharts.dateFormat('%H:%M:%S', new Date(this.x + #{@grouping_factor})) + '<br/>' +
                 '<b>#{I18n.t('activerecord.models.runner')}: </b>' +
                 this.y;
        }".js_code
    )
    self.plotOptions(column: {
        groupPadding: 0,
        pointPadding: 0,
        borderWidth: 0
    })
    self.legend(enabled: false)
  end
end