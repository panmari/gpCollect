class RuntimeChart < LazyHighCharts::HighChart
  include ChartHelpers

  def initialize(type = 'graph')
    super(type)
    @all_run_days = RunDay.all.ordered_by_date
    set_options
  end

  protected

  def generate_json_from_array(array)
    array.map { |value| generate_json_from_value(value) }.join(',')
  end

  def make_runs_data(runner)
    @all_run_days.map do |rd|
      run = runner.runs.find { |r| r.run_day == rd }
      duration = (yield(run) if run)
      [date_to_miliseconds(rd.date), duration]
    end
  end

  private

  def set_options
    title(text: nil)
    x_axis_ticks = @all_run_days.map { |run_day| date_to_miliseconds(run_day.date) }
    xAxis(type: 'datetime',
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
    yAxis(type: 'datetime', # y-axis will be in milliseconds
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
          title: { text: I18n.t('runtime_chart.time') })
    tooltip(
      useHTML: true,
      # shared: true,
      formatter: "function() {
        return '<b>' + this.series.name +'</b><br/>' +
            Highcharts.dateFormat('%e. %b. %Y', new Date(this.x)) + '<br/>' +
            Highcharts.dateFormat('%H:%M:%S', new Date(this.y));
      }".js_code
    )
    legend(layout: 'horizontal')
  end
end
