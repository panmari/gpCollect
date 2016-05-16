class Run < ActiveRecord::Base
  belongs_to :runner, counter_cache: true
  belongs_to :category
  belongs_to :run_day
  belongs_to :run_day_category_aggregate, :foreign_key => [:run_day_id, :category_id]

  # Only available for runs with run_day.date >= 2010
  def alpha_foto_url?
    run_day.alpha_foto_id and start_number
  end

  def alpha_foto_url
    if alpha_foto_url?
      "https://www.alphafoto.com/images.php?runID=#{run_day.alpha_foto_id}&sn=#{start_number}"
    end
  end

  def rank
    result = ActiveRecord::Base.connection.execute(<<-SQL
      SELECT rank
      FROM (
        SELECT runs.id AS id, rank() OVER (ORDER BY duration)
        FROM runs
        WHERE run_day_id = #{self.run_day_id}) Filtered
      WHERE id = #{self.id}
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
        WHERE run_day_id = #{self.run_day_id} AND
          category_id = #{self.category_id}) Filtered
      WHERE id = #{self.id}
      SQL
    )
    result.first['rank']
  end
end
