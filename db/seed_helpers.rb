require 'csv'

# Helpers for seeding raw data into database.
module SeedHelpers
  DURATION_REGEXP = /(?:(?<hours>\d{1,2}):)?(?<minutes>\d{2}):(?<seconds>\d{2})(?:\.(?<hundred_miliseconds>\d))?/

  def self.input_files_hash
    route_16km = Route.find_or_create_by!(length: 16.093)
    gp_bern_organizer = Organizer.find_or_create_by!(name: 'Grand Prix von Bern')

    scraped = (1999..2006).map do |year|
      { file: "db/data/gp_bern_10m_#{year}.csv",
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(year),
                                           route: route_16km) }
    end
    scraped_new = [Date.new(2007, 0o5, 12),
                   Date.new(2008, 0o5, 10)].map do |date|
      { file: "db/data/gp_bern_10m_#{date.year}.csv",
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: date,
                                           route: route_16km),
        shift: -1, duration_shift: -1 }
    end

    modern = [
      { file: 'db/data/gp_bern_10m_2009.csv', shift: -1,
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2009, 4, 18),
                                           route: route_16km) },
      { file: 'db/data/gp_bern_10m_2010.csv', shift: -1,
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2010, 5, 22),
                                           route: route_16km) },
      { file: 'db/data/gp_bern_10m_2011.csv', shift: -1,
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2011, 5, 14),
                                           route: route_16km) },
      { file: 'db/data/gp_bern_10m_2012.csv', shift: -1,
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2012, 5, 12),
                                           route: route_16km) },
      { file: 'db/data/gp_bern_10m_2013.csv',
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2013, 5, 18),
                                           route: route_16km) },
      { file: 'db/data/gp_bern_10m_2014.csv',
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2014, 5, 10),
                                           route: route_16km) },
      { file: 'db/data/gp_bern_10m_2015.csv',
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2015, 5, 9),
                                           route: route_16km) },
      { file: 'db/data/gp_bern_10m_2016.csv', col_sep: ',',
        interim_times_count: 3,
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2016, 5, 14),
                                           route: route_16km) },
      { file: 'db/data/gp_bern_10m_2017.csv', col_sep: ',', interim_col: 9,
        interim_times_count: 4, duration_col: 14, category_col: 6,
        club_or_hometown_col: 7,
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2017, 5, 13),
                                           route: route_16km,
                                           alpha_foto_id: '869') },
      { file: 'db/data/gp_bern_10m_2018.csv', col_sep: ',', interim_col: 9,
        interim_times_count: 4, duration_col: 14, category_col: 5,
        club_or_hometown_col: 6,
        run_day: RunDay.find_or_create_by!(organizer: gp_bern_organizer,
                                           date: Date.new(2018, 5, 19),
                                           route: route_16km,
                                           alpha_foto_id: '869') }

    ]
    scraped + scraped_new + modern
  end

  def self.create_progressbar_for(file)
    ProgressBar.create(total: `wc -l #{file}`.to_i, format: '%B %R runs/s, %a', throttle_rate: 0.1)
  end

  # TODO: Possibly handle disqualified cases better.
  # Right now they have nil as duration (but still have an entry in the run table).
  def self.duration_string_to_ms(duration_string, allow_blank = false)
    if (duration_string == 'DSQ') || (duration_string.blank? && allow_blank)
      nil
    else
      matches = duration_string.match(DURATION_REGEXP)
      ((matches[:hours] || 0).to_i * 3600 + matches[:minutes].to_i * 60 + matches[:seconds].to_i) * 1000 +
        (matches[:hundred_miliseconds] || 0).to_i * 100
    end
  end

  @categories = {}
  # Finds category with some memoization.
  def self.find_or_create_category_for(category_string)
    if @categories[category_string]
      @categories[category_string]
    else
      category_hash = {}
      category_string.match /([MW])U?(\d{1,3})/ do |matches|
        category_hash[:sex] = matches[1]
        if category_string[1] == 'U'
          category_hash[:age_max] = matches[2].to_i
        else
          category_hash[:age_min] = matches[2].to_i
        end
      end
      category = Category.find_or_create_by!(category_hash)
      @categories[category_string] = category
      category
    end
  end

  def self.find_or_create_runner_for(runner_hash, run_day, category)
    # only possible matches are runners that match all attribute and don't have a run already registered on that day.
    possible_matches = Runner.includes(:run_days).where(runner_hash)
    possible_matches = possible_matches.reject { |r| r.run_days.any? { |occupied_run_day| occupied_run_day == run_day } }

    estimated_birth_date = run_day.date - (category.age_max || category.age_min).years
    # Check which runner is closest in birth date
    closest_birth_date_diff, closest_birth_date_idx =
      possible_matches.map { |r| (r.birth_date - estimated_birth_date).abs }.each_with_index.min
    # TODO: Don't only use age for finding closest match, but also duration of run vs average duration of runs.
    runner = if closest_birth_date_diff && (closest_birth_date_diff < 10 * 365)
               possible_matches[closest_birth_date_idx]
             else
               Runner.new(runner_hash.merge(birth_date: estimated_birth_date))
             end
    if category.age_max && (runner.birth_date < estimated_birth_date)
      # Estimated age is a lower bound here, update to it if higher than previous estimate.
      runner.birth_date = estimated_birth_date
    elsif category.age_min && (runner.birth_date > estimated_birth_date)
      # Estimated age is an upper bound here, update to it if lower than previous estimate.
      runner.birth_date = estimated_birth_date
    end
    runner.save!
    runner
  end

  NAME_REGEXP = /(?<last_name>[^,]*), (?<first_name>[^(]+?) ?(?:\((?<nationality>[A-Z]*)\))?$/

  # Seeds a file with the given options. Options are expected to have the following keys:
  # * file: The file to be seeded
  # * run_day: The run day the runs to be seeded belong to
  #
  # Optionally taking the following keys:
  # * shift: Additional shift of ALL read out columns, if format does not match exactly.
  # * duration_shift: additional shift for duration column.
  # * interim_times_count: Number of additional measurements before final time, 2 by default.
  def self.seed_runs_file(options)
    file = options.fetch(:file)
    shift = options.fetch(:shift, 0)
    duration_shift = options.fetch(:duration_shift, 0)
    col_sep = options.fetch(:col_sep, ';')
    interim_times_count = options.fetch(:interim_times_count, 2)

    start_number_col = options.fetch(:start_number_col, 3 + shift)
    category_col = options.fetch(:category_col, 5 + shift)
    club_or_hometown_col = options.fetch(:club_or_hometown_col, 6 + shift)
    interim_col = options.fetch(:interim_col, 8 + shift + duration_shift)
    duration_col = options.fetch(:duration_col, 8 + interim_times_count + shift + duration_shift)

    puts "Seeding #{file} "
    progressbar = create_progressbar_for(file)

    run_day = options.fetch(:run_day)
    ActiveRecord::Base.transaction do
      CSV.foreach(file, headers: true, col_sep: col_sep) do |line|
        begin
          runner_hash = {}
          name = line[4 + shift]
          category_string = line[category_col]
          club_or_hometown = line[club_or_hometown_col]
          runner_hash[:club_or_hometown] = club_or_hometown.blank? ? nil : club_or_hometown
          duration_string = line[duration_col]

          # Don't create a runner/run if there is no category or duration
          # (including > 2h) associated.
          next if line[0] == '&gt'
          next if category_string.blank? || duration_string.blank?

          # Only match if only consists of numbers with some optional prefix.
          start_number = line[start_number_col].scan(/^[MK]?[0-9]+$/)[0]

          # E. g. 'Abati, Mauro (SUI)'
          m = NAME_REGEXP.match(name)
          if m
            runner_hash[:last_name] = m[:last_name].tr('0', 'o').titleize
            runner_hash[:first_name] = m[:first_name].tr('0', 'o').titleize
            runner_hash[:nationality] = m[:nationality]
          else
            # Known issue: in 2013 file there are some names that only consist of nationality, skip these
            if name =~ /\([A-Z]{3}\)/
              next
            elsif name =~ /\([0-9]{1,3}\)/ # Known issue: Nationality consist of numbers -> next
              next
            else
              raise 'Could not parse name: ' + name
            end
          end

          category = find_or_create_category_for(category_string)
          runner_hash[:sex] = category.sex

          runner = find_or_create_runner_for(runner_hash, run_day, category)

          interim_times = interim_times_count.times.map do |interim_idx|
            duration_string_to_ms(line[interim_col + interim_idx], true)
          end
          Run.create!(start_number: start_number, runner: runner,
                      category: category,
                      duration: duration_string_to_ms(duration_string),
                      run_day: run_day, interim_times: interim_times)
          progressbar.increment
        rescue Exception => e
          puts "Failed parsing: #{line}"
          raise e
        end
      end
    end
    progressbar.finish
  end
end
