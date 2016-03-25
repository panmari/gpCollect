# encoding: UTF-8
module MergeRunnersHelpers
  def self.merge_runners(runner, to_be_merged_runner)
    runner.runs += to_be_merged_runner.runs
    runner.save!
    to_be_merged_runner.destroy!
  end

  def self.find_runners_only_differing_in(attr, additional_attributes_select=[], additional_attributes_group=[])
    identifying_runner_attributes_select = [:first_name, :last_name, :nationality, :club_or_hometown, :sex]
    identifying_runner_attributes_group = [:first_name, :last_name, :nationality, :club_or_hometown, :sex]
    r = Runner.select(identifying_runner_attributes_select - [attr].flatten + additional_attributes_select + ['array_agg(id) AS ids'])
            .group(identifying_runner_attributes_group - [attr].flatten + additional_attributes_group).having('count(*) > 1')
    # Each merge candidate consists of multiple runners, retrieve these runners from database here.
    merge_candidates = r.map { |i| Runner.includes(:run_days).find(i['ids']) }
    # Only select the runners as merge candidates that differ in the queried attribute.

    # TODO: possibly remove this.
    merge_candidates.select! {|i| i.first[attr] != i.second[attr]}

    # TODO: Remove candidates that have a too large discrepancy in age.
    # merge_candidates.select! {|i| i.birth_date - }

    # Only select runners for merging that have no overlapping run days.
    merge_candidates.select {|i| i.all? {|fixed_runner| (i - [fixed_runner]).all? { |other_runner| (fixed_runner.run_days & other_runner.run_days).empty? }}}
  end

  def self.count_accents(string)
    # [[:alpha:]] will match accented characters, \w will not.
    (string.scan(/[[:alpha:]]/) - string.scan(/\w/)).size
  end

  MALE_FIRST_NAMES = %w(Jannick Candido Loïc Patrick Raffael Kazim Luca Manuel Patrice Eric Yannick)
  FEMALE_FIRST_NAMES = %w(Denise Tabea Capucine Lucienne Carole Dominique)
  POSSIBLY_WRONGLY_ACCENTED_ATTRIBUTES = [:first_name, :last_name]
  POSSIBLY_WRONGLY_CASED_ATTRIBUTES = [:club_or_hometown]
  POSSIBLY_WRONGLY_SPACED_ATTRIBUTES = [:first_name, :last_name, :club_or_hometown]
  POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES = [:first_name, :last_name, :club_or_hometown]

  def self.merge_duplicates
    self.merge_duplicates_based_on_sex
    self.merge_duplicates_based_on_nationality
    self.merge_duplicates_based_on_accents
    self.merge_duplicates_based_on_case
    self.merge_duplicates_based_on_space
    self.merge_duplicates_based_on_umlaute
    self.merge_duplicates_based_on_hometown_prefix
  end

  # Handle wrong sex, try to find correct sex using name list.
  def self.merge_duplicates_based_on_sex
    merged_runners = 0
    find_runners_only_differing_in(:sex).each do |entries|
      first_name = entries.first.first_name
      correct_sex = if MALE_FIRST_NAMES.include?(first_name)
                      'M'
                    elsif FEMALE_FIRST_NAMES.include?(first_name)
                      'W'
                    else
                      raise "Could not match gender to #{entries}, please extend names list."
                    end
      merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
        # TODO: Specify which one to pick if there are multiple runners with the correct sex.
        runner.sex == correct_sex ? 1 : 0
      end
    end
    puts "Merged #{merged_runners} entries based on sex."
  end

  def self.merge_duplicates_based_on_nationality
    merged_runners = 0
    find_runners_only_differing_in(:nationality).each do |entries|
      # Use most recently known nationality for runner that has a non-blank nationality.
      correct_entry = entries.reject { |entry| entry.nationality.blank? }.max_by { |entry| entry.run_days.max_by(&:date) }
      wrong_entries = entries.reject { |entry| entry == correct_entry }
      wrong_entries.each { |entry| merge_runners(correct_entry, entry) }
      merged_runners += wrong_entries.size
    end
    puts "Merged #{merged_runners} entries based nationality"
  end

  def self.merge_duplicates_based_on_accents
    POSSIBLY_WRONGLY_ACCENTED_ATTRIBUTES.each do |attr|
      merged_runners = 0
      find_runners_only_differing_in(attr, ["f_unaccent(#{attr}) as unaccented"], ['unaccented']).each do |entries|
        # The correct entry is the one with more accents (probably?).
        merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
          count_accents(runner[attr])
        end
      end
      puts "Merged #{merged_runners} entries based on accents of #{attr}."
    end
  end

  # Try to fix case sensitive duplicates in club_or_hometown, e. g. in
  # Veronique	Plessis	Arc Et Senans
  # Veronique	Plessis	Arc et Senans
  def self.merge_duplicates_based_on_case
    POSSIBLY_WRONGLY_CASED_ATTRIBUTES.each do |attr|
      merged_runners = 0
      find_runners_only_differing_in(attr, ["f_unaccent(lower(#{attr})) as low"], ['low']).each do |entries|
        # We take the one with more lowercase characters as he correct one. E. g. for
        # Reichenbach I. K.
        # Reichenbach i. K.
        # the version at the bottom is preferred.
        merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
          runner[attr].scan(/[[:lower:]]/).size
        end
      end
      puts "Merged #{merged_runners} entries based on case of #{attr}."
    end
  end

  def self.merge_duplicates_based_on_space
    POSSIBLY_WRONGLY_SPACED_ATTRIBUTES.each do |attr|
      merged_runners = 0
      find_runners_only_differing_in(attr, ["replace(#{attr}, '-', ' ') as spaced"], ['spaced']).each do |entries|
        # We take the one with more spaces as he correct one.
        merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
          runner[attr].scan(/ /).size
        end
      end
      puts "Merged #{merged_runners} entries based on spaces of #{attr}."
    end
  end

  def self.merge_duplicates_based_on_umlaute
    POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES.each do |attr|
      merged_runners = 0
      find_runners_only_differing_in(attr, ["replace(replace(replace(lower(#{attr}), 'ae', 'ä'), 'oe', 'ö'), 'ue', 'ü') as with_umlaut"],
                                     ['with_umlaut']).each do |entries|
        # assume the correct entry is the one with more Umlaute,
        # as there seemed to be no unicode support in earlier data.
        merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
          runner[attr].count('äüöÄÜÖ')
        end
      end
      puts "Merged #{merged_runners} entries based on Umlaute in #{attr}"
    end
  end

  # A runner might appear with two similar hometowns, e. g. once with 'Muri b. Bern' and once with 'Muri'.
  def self.merge_duplicates_based_on_hometown_prefix
    merged_runners = 0
    prefix_length = 4
    find_runners_only_differing_in(:club_or_hometown,
                                   ["substring(club_or_hometown, 0, #{prefix_length}) as prefix_only_attr"],
                                   ['prefix_only_attr']).each do |entries|
      # The longer club_or_hometown entry is assumed to be correct/contains more information.
      merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
        runner[:club_or_hometown].length
      end
    end
    puts "Merged #{merged_runners} entries based on prefix of club or hometown"
  end

  # Reduces the given entries to only one, chosen by the block passed.
  # The one that evaluates to the maximum of the block passed will be retained, the others merged with it.
  def self.reduce_to_one_runner_by_condition(entries, &block)
    correct_entry = entries.max_by { |entry| yield(entry) }
    wrong_entries = entries.reject { |entry| entry == correct_entry }
    wrong_entries.each { |entry| merge_runners(correct_entry, entry) }
    wrong_entries.size
  end

    # TODO: Try to fix club_or_hometown duplicates, e. g.
    # Achim	Seifermann	LAUFWELT de Lauftreff
    # Achim	Seifermann	Laufwelt.de
    #only_differing_club_or_hometown = Runner.select(identifying_runner_attributes - [:club_or_hometown])
    #                                      .group(identifying_runner_attributes - [:club_or_hometown]).having('count(*) > 1')
end
