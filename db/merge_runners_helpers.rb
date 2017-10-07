# encoding: UTF-8
module MergeRunnersHelpers
  def self.merge_runners(runner, to_be_merged_runner)
    runner.runs += to_be_merged_runner.runs
    # TODO: Do something to update estimated birthday.
    runner.save!
    to_be_merged_runner.destroy!
  end

  # Returns 1 if a > b (e. g. M30 > MU18)
  def self.compare_categories(a, b)
    [a.age_min || 0, a.age_max || 0, a.sex] <=> [b.age_min || 0, b.age_max || 0, b.sex]
  end

  # TODO: In 2005, categories changed. E. g. M35 doesn't exist anymore, moving runners from this category to M30 in the
  # next year. This method will with it's current implementation return false for these cases.
  def self.check_runs_for_ascending_categories(runs)
    runs.sort_by(&:run_day).each_cons(2).all? do |previous_run, run|
      self.compare_categories(previous_run.category, run.category) <= 0
    end
  end

  def self.find_runners_only_differing_in(attr, additional_attributes_select=[], additional_attributes_group=[],
      options={})
    identifying_runner_attributes_select = [:first_name, :last_name, :nationality, :club_or_hometown, :sex]
    identifying_runner_attributes_group = [:first_name, :last_name, :nationality, :club_or_hometown, :sex]
    removed_attributes = options.fetch(:removed_attributes, [])
    corpus = options.fetch(:corpus, Runner.all)

    r = corpus
            .select(identifying_runner_attributes_select - removed_attributes - [attr].flatten +
                        additional_attributes_select + ['array_agg(id) AS ids'])
            .group(identifying_runner_attributes_group - removed_attributes -[attr].flatten +
                       additional_attributes_group).having('count(*) > 1')
    # Each merge candidate consists of multiple runners, retrieve these runners from database here.
    merge_candidates = r.map { |i| Runner.includes(:run_days, runs: [:run_day, :category]).find(i['ids']) }
    # Only select the runners as merge candidates that differ in the queried attribute.

    # TODO: possibly remove this.
    # Only select runners that actually differ in the given attribute.
    merge_candidates.select! { |i| [attr].flatten.any? { |a| i.first[a] != i.second[a] } }

    # A runner can not suddenly get younger, so check if categories are ascending.
    merge_candidates.select! do |runners|
      self.check_runs_for_ascending_categories(runners.map(&:runs).flatten)
    end

    # Only select runners for merging that have no overlapping run days.
    merge_candidates.select { |i| i.all? { |fixed_runner| (i - [fixed_runner]).all? { |other_runner| (fixed_runner.run_days & other_runner.run_days).empty? } } }
  end

  def self.count_accents(string)
    # [[:alpha:]] will match accented characters, \w will not.
    (string.scan(/[[:alpha:]]/) - string.scan(/\w/)).size
  end

  MALE_FIRST_NAMES = %w(Jannick Candido Loïc Patrick Raffael Kazim Luca Manuel Patrice Eric Yannick Emanuil Mathieu Nicolo)
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
    self.merge_duplicates_based_on_msm_prefix
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
                      puts "Could not match gender to #{entries}, please type M/W and extend names list."
		      STDIN.gets.chomp.upcase
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
      # Use most recent non-blank nationality.
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
      find_runners_only_differing_in(attr, ["lower(regexp_replace(#{attr}, '[- ]', '', 'g')) as unspaced"], ['unspaced']).each do |entries|
        # We take the one with more spaces as he correct one.
        # Except when there is a version with consecutive spaces such as
        #   La Tour-de -Peilz
        merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
          [-runner[attr].scan(/[- ]{2,}/).size, runner[attr].scan(/[ -]/).size]
        end
      end
      puts "Merged #{merged_runners} entries based on spaces of #{attr}."
    end
  end

  def self.merge_duplicates_based_on_umlaute
    # Allow missing umlaut to be in any attribute (it may occur that it's missing in the last name and hometown).
    select_statement = POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES.each_with_index.map do |attr, idx|
      "replace(replace(replace(lower(#{attr}), 'ae', 'ä'), 'oe', 'ö'), 'ue', 'ü') as with_umlaut_#{idx}"
    end
    group_attributes = POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES.each_with_index.map { |_, idx| "with_umlaut_#{idx}" }

    merged_runners = 0
    find_runners_only_differing_in(POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES, select_statement,
                                   group_attributes, {removed_attributes: [:nationality]}).each do |entries|
      # assume the correct entry is the one with more Umlaute,
      # as there seemed to be no unicode support in earlier data.
      merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
        POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES.inject(0) { |sum, attr| sum + runner[attr].count('äüöÄÜÖ') }
      end
    end
    puts "Merged #{merged_runners} entries based on Umlaute in any of #{attr}"
  end

  # A runner might appear with two similar hometowns, e. g. once with 'Muri b. Bern' and once with 'Muri'.
  def self.merge_duplicates_based_on_hometown_prefix
    merged_runners = 0
    prefix_length = 4
    find_runners_only_differing_in(:club_or_hometown,
                                   ["lower(substring(club_or_hometown, 0, #{prefix_length})) as prefix_only_attr"],
                                   ['prefix_only_attr']).each do |entries|
      # The longer club_or_hometown entry is assumed to be correct/contains more information.
      # If there is a version with all uppercase, it is disprioritized.
      merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
        if runner[:club_or_hometown].upcase == runner[:club_or_hometown]
          -1
        else
          runner[:club_or_hometown].length
        end
      end
    end
    puts "Merged #{merged_runners} entries based on prefix of club or hometown"
  end

  # A runner might appear with two similar clubs,
  # e. g. once with 'MSM - BFE Berufsfachschule Emmental' and once with 'BFE Berufsfachschule Emmental'.
  def self.merge_duplicates_based_on_msm_prefix
    merged_runners = 0
    suffix_length = 4
    attribute = :club_or_hometown
    find_runners_only_differing_in(attribute, ["lower(replace(#{attribute},'MSM - ', '')) as no_msm_prefix"], ['no_msm_prefix']).each do |entries|
      # Pick the version including 'MSM' (is always the longer one).
      merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
        runner[:club_or_hometown].length
      end
    end
    puts "Merged #{merged_runners} entries based on prefix MSM prefix"
  end

  # A runner might appear with two similar clubs,
  # TODO: clean this up, e. g. by running on restricted corpus.
  # As it is now, it might merge 'Zollikofen' with 'Rennclub Zollikofen', which might not be the preferred behavior
  # (Since these are two different entities, unlike the other merges that just try to rectify typos/variation of writings of the same entity).
  # This kind of merge should probably only be done manually.
  def self.merge_duplicates_based_on_hometown_suffix
    merged_runners = 0
    suffix_length = 4
    attribute = :club_or_hometown
    find_runners_only_differing_in(attribute, ["lower(substring(#{attribute} from length(#{attribute}) - #{suffix_length})) as suffix_only_attr"], ['suffix_only_attr']).each do |entries|
      # The longer club_or_hometown entry is assumed to be correct/contains more information.
      # If there is a version with all uppercase, it is disprioritized.
      merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
        if runner[:club_or_hometown].upcase == runner[:club_or_hometown]
          -1
        else
          runner[:club_or_hometown].length
        end
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
end
