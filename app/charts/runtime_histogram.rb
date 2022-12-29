# frozen_string_literal: true

class RuntimeHistogram < LazyHighCharts::HighChart
  def initialize(options = {})
    super(type: 'column')
    @category = options.fetch(:category, nil)
    @runner_constraint = options.fetch(:runner_constraint, nil)
    # A groupping factor 30000 will lead to buckets of size 30 seconds.
    @grouping_factor = if @runner_constraint
                         120_000
                       else
                         30_000
                       end
    @highlighted_run = options.fetch(:highlighted_run, nil)
    highlighted_key = @highlighted_run.duration / @grouping_factor if @highlighted_run

    runs = if @category
             Run.where(category: @category)
           else
             Run.all
           end
    unless @runner_constraint.blank?
      runs = runs.includes(:runner).where(runners: @runner_constraint)
    end
    data = Rails.cache.fetch("hist_data_#{begin
                                            @category.id
                                          rescue StandardError
                                            'all'
                                          end}") do
      runs.where.not(duration: nil)
          .group("duration / #{@grouping_factor}")
          .order("duration_#{@grouping_factor}")
          .count
    end

    # Bring back to correct range and highlight if necessary.
    data_series = data.map do |a|
      if a[0] == highlighted_key
        { x: a[0] * @grouping_factor, y: a[1], color: 'red', marker: {} }
      else
        [a[0] * @grouping_factor, a[1]]
      end
    end

    set_options

    series(data: data_series, id: 'hist', name: 'hist')
    if @highlighted_run
      series(
        type: 'flags',
        name: 'Highcharts',
        color: '#333333',
        data: [
          { x: highlighted_key * @grouping_factor,
            text: "In #{@highlighted_run.run_day.year} was #{@highlighted_run.decorate.duration_formatted}",
            title: @highlighted_run.runner.decorate.name }
        ],
        showInLegend: false,
        onSeries: 'hist'
      )
    end
  end

  private

  def set_options
    chart(type: 'column')
    xAxis(type: 'datetime', # y-axis will be in milliseconds
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
        if (this.series.name == 'hist')
          return '<b>#{I18n.t('runtime_chart.time')}: </b>' +
                 Highcharts.dateFormat('%H:%M:%S', new Date(this.x)) +
                 ' - ' +
                 Highcharts.dateFormat('%H:%M:%S', new Date(this.x + #{@grouping_factor})) + '<br/>' +
                 '<b>#{I18n.t('activerecord.models.runner')}: </b>' +
                 this.y;
        else
          return this.point.text;
      }".js_code
    )
    plotOptions(column: {
                  groupPadding: 0,
                  pointPadding: 0,
                  borderWidth: 0
                })
    legend(enabled: false)
  end
end
