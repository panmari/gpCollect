class RuntimeChart < LazyHighCharts::HighChart
  def initialize(type='graph')
    super(type)
    @all_run_days = RunDay.all
    set_options
  end

  protected

  def generate_json_from_array array
    array.map { |value| generate_json_from_value(value) }.join(",")
  end

  def make_runs_data(runner, &block)
    @all_run_days.map do |rd|
      run = runner.runs.find { |r| r.run_day == rd }
      duration = if run
                   yield(run)
                 else
                   nil
                 end
      [LazyHighCharts::OptionsKeyFilter.date_to_js_code(rd.date), duration]
    end
  end

  private

  def set_options
    self.title(text: nil)
    x_axis_ticks = @all_run_days.map { |run_day| LazyHighCharts::OptionsKeyFilter.date_to_js_code(run_day.date) }
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
    self.yAxis(type: 'datetime', # y-axis will be in milliseconds
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
               title: { text: 'Time'}
    )
    self.tooltip(
        useHTML: true,
        #shared: true,
        formatter: "function() {
          return '<b>' + this.series.name +'</b><br/>' +
              Highcharts.dateFormat('%e. %b. %Y', new Date(this.x)) + '<br/>' +
              Highcharts.dateFormat('%H:%M:%S', new Date(this.y));
        }".js_code
    )
    self.legend(layout: 'horizontal')
  end

  ### Copied private helpers from lazy_high_charts/lib/lazy_high_charts/layout_helper.rb

  def generate_json_from_value value
    if value.is_a? Hash
      %|{ #{generate_json_from_hash value} }|
    elsif value.is_a? Array
      %|[ #{generate_json_from_array value} ]|
    elsif value.respond_to?(:js_code) && value.js_code?
      value
    else
      value.to_json
    end
  end
end