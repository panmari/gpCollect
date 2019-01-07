# frozen_string_literal: false

class ParticipantsChart < LazyHighCharts::HighChart
  include ChartHelpers

  # Creates a chart visualizing number of participants over time, filtered to
  # the given category.
  # If category is nil, participants over all categories are summed up.
  def initialize(category)
    super('graph')
    chart(type: 'area')
    legend(enabled: false)

    join = RunDay.left_outer_joins(:run_day_category_aggregates)
                 .group(:date)
                 .order(:date)
    unless category.nil?
      # Sum still works even if we constrain to only one category.
      join = join.where(run_day_category_aggregates: { category_id: category })
    end
    agg = join.sum(:runs_count)
    series(data: agg.map { |date, count| [date_to_miliseconds(date), count] })

    x_axis_ticks = agg.map { |date, _| date_to_miliseconds(date) }
    yAxis(title: { text: I18n.t('participiants_chart.x_axis_label') })
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
    tooltip(
      useHTML: true,
      formatter: "function() {
        return Highcharts.dateFormat('%e. %b. %Y', new Date(this.x)) + '<br/>' + this.y;
      }".js_code
    )
  end
end
