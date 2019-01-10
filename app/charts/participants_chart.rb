# frozen_string_literal: false

# Represents a chart visualizing number of participants over time.
# Must be extended and have data added.
class ParticipantsChart < LazyHighCharts::HighChart
  include ChartHelpers

  def initialize
    super('graph')
    yAxis(title: { text: I18n.t('participants_chart.x_axis_label') }, min: 0)
    xAxis(type: 'datetime')
    tooltip(dateTimeLabelFormats: { hour: '%Y' })
  end
end
