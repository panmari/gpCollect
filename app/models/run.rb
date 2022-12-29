# frozen_string_literal: true

class Run < ActiveRecord::Base
  belongs_to :runner, counter_cache: true
  belongs_to :category
  belongs_to :run_day
  belongs_to :run_day_category_aggregate,
             foreign_key: %i[run_day_id category_id],
             optional: true # Added after inserting all runs.

  scope :ordered, -> { joins(:run_day).order(date: :asc).references(:run_day) }

  # Only available for runs with run_day.date >= 2010
  def alpha_foto_url?
    run_day.alpha_foto_id && start_number
  end

  def alpha_foto_url
    return unless alpha_foto_url?
    "https://www.alphafoto.com/images.php?runID=#{run_day.alpha_foto_id}&sn=#{start_number}"
  end

  # If 5 times are available, they correspond to [2.2, 5, 5 miles, 10, 12.8] km
  # If 4: [2.2, 5, 10, 12.8] km
  # If 3: [5, 10, 12.5] km
  # If 2: [5, 10] km
  # This method pads all arrays available to size 4.
  # TODO: 12.5 != 12.8, handle this case better.
  def interim_times
    t = self[:interim_times]
    case t.size
    when 4
      return [t[0], t[1], nil, t[2], t[3]]
    when 3
      return [nil, t[0], nil, t[1], t[2]]
    when 2
      return [nil, t[0], nil, t[1], nil]
    else
      return t
    end
  end

  def rank
    result = ActiveRecord::Base.connection.execute(<<-SQL
      SELECT rank
      FROM (
        SELECT runs.id AS id, rank() OVER (ORDER BY duration)
        FROM runs
        WHERE run_day_id = #{run_day_id}) Filtered
      WHERE id = #{id}
      LIMIT 1
    SQL
                                                  )
    result.first['rank']
  end

  def category_rank
    result = ActiveRecord::Base.connection.execute(<<-SQL
      SELECT rank
      FROM (
        SELECT runs.id AS id, rank() OVER (ORDER BY duration)
        FROM runs
        WHERE run_day_id = #{run_day_id} AND
          category_id = #{category_id}) Filtered
      WHERE id = #{id}
      LIMIT 1
      SQL
                                                  )
    result.first['rank']
  end
end
