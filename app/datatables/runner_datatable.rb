class RunnerDatatable < AjaxDatatablesRails::Base
#  include ActiveRecord::Sanitization::ClassMethods

  def_delegators :@view, :runner_path, :remember_runner_path, :link_to, :fa_icon, :content_tag

  def view_columns
    @view_columns ||= {
      first_name: { source: 'Runner.first_name', searchable: true },
      last_name: { source: 'Runner.last_name', searchable: true },
      club_or_hometown: { source: 'Runner.club_or_hometown', searchable: true },
      sex: { source: 'Runner.sex', searchable: false },
      nationality: { source: 'Runner.nationality', searchable: false },
      runs_count: { source: 'Runner.runs_count', searchable: false },
      fastest_run_duration: { searchable: false, orderable: false },
      links: { searchable: false, orderable: false },
    }
  end

  # Cache counts for efficiency.
  def records_total_count
    Rails.cache.fetch('raw_count') { get_raw_records.count(:all) }
  end

  # Use optimized counts defined in fetch_records (postgresql specific).
  def records_filtered_count
    (records.blank? ? 0 : records.first['filtered_count']) || records_total_count
  end

  def records
    @records ||= ActiveRecord::Base.transaction do
      # Disable index scan in case a search filter is given. This makes sql
      # choose the 'gin' index for these queries, returning results much faster.
      ActiveRecord::Base.connection.execute('SET LOCAL enable_indexscan = off;') if datatable.search.value
      retrieve_records.load
    end
  end

  def data
    RunnerDecorator.decorate_collection(records).map do |record|
      {
          first_name: record.first_name,
          last_name: record.last_name,
          club_or_hometown: record.club_or_hometown,
          sex: record.sex,
          nationality: record.nationality,
          runs_count: record.runs_count,
          fastest_run_duration: record.fastest_run_duration,
          # TODO: only send id and name, then generate links in javascript.
          links: link_to(fa_icon('eye lg'), runner_path(record), class: 'btn btn-primary',
                  title: I18n.t('runner_datatable.show_hint')) + ' ' +
              link_to(content_tag(:i, '', class: 'fa fa-lg'), '#', title: I18n.t('runner_datatable.remember_runner'),
                      data: {remember_runner: record.id,
                             remember_runner_name: record.name}, class: 'btn btn-info')
      }
    end
  end

  def get_raw_records
    Runner.all.includes(:runs)
  end

  def retrieve_records
    records = fetch_records
    # TODO: Figure out why simply overriding filter_records does not work,
    # then rename filter_records_with_gin and delete retrieve_records
    records = filter_records_with_gin(records)
    records = sort_records(records)     if datatable.orderable?
    records = paginate_records(records) if datatable.paginate?
    records
  end

  # Overrides the filter method defined from the gem. When searching, we ignore all accents, so a search for 'théo'
  # will also return 'theo' (and vice-versa).
  # Every word (separated by space) will be searched individually in all searchable columns. Only rows that satisfy all
  # words (in some column) are returned.
  def filter_records_with_gin(records)
    if datatable.search.value
      Rails.logger.debug(datatable.search.value)
      search_for = datatable.search.value.split(' ')
      # The index only works for terms of length 3 and longer, so shorter terms are filtered here.
      search_for.reject! {|i| i.length < 3 }
      where_clause = search_for.map do |unescaped_term|
        first_column = searchable_columns.first
        first_arel_field = first_column.table[first_column.field]
        concatenated = searchable_columns[1..-1].inject(first_arel_field) do |concated, c|
          arel_field = c.table[c.field]
          concated.concat(::Arel::Nodes::build_quoted(';')).concat(arel_field)
        end
        unaccented_concatenated = ::Arel::Nodes::NamedFunction.new('f_unaccent', [concatenated])
        term = "%#{sanitize_sql_like(unescaped_term)}%"
        unaccented_concatenated.matches(::Arel::Nodes::NamedFunction.new('f_unaccent', [::Arel::Nodes::build_quoted(term)]))
      end.reduce(:and)
      # Do filtered counts here instead of calling count again later.
      records.select('*, count(*) OVER() as filtered_count').where(where_clause)
    else
      records
    end
  end

  private

  # Sanitizes a +string+ so that it is safe to use within an SQL
  # LIKE statement. This method uses +escape_character+ to escape all occurrences of "\", "_" and "%"
  def sanitize_sql_like(string, escape_character = "\\")
    pattern = Regexp.union(escape_character, "%", "_")
    string.gsub(pattern) { |x| [escape_character, x].join }
  end

end
