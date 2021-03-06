# frozen_string_literal: true

class MergeRunnersHelpers
  def initialize(auto_approve = false)
    @auto_approve = auto_approve
  end

  def find_runners_only_differing_in(attr, additional_attributes_select = [],
                                     additional_attributes_group = [],
                                     options = {})
    identifying_runner_attributes_select = %i[first_name last_name nationality club_or_hometown sex]
    identifying_runner_attributes_group = %i[first_name last_name nationality club_or_hometown sex]
    removed_attributes = options.fetch(:removed_attributes, [])
    corpus = options.fetch(:corpus, Runner.all)

    r = corpus
        .select(identifying_runner_attributes_select - removed_attributes - [attr].flatten +
                        additional_attributes_select + ['array_agg(id) AS ids'])
        .group(identifying_runner_attributes_group - removed_attributes - [attr].flatten +
                       additional_attributes_group).having('count(*) > 1')
    # Each merge candidate consists of multiple runners, retrieve these runners from database here.
    merge_candidates = r.map do |i|
      Runner.includes(:run_days, runs: %i[run_day category]).find(i['ids'])
    end
    # TODO: possibly remove this.
    # Only select runners that actually differ in the given attribute.
    merge_candidates.select! { |i| [attr].flatten.any? { |a| i.first[a] != i.second[a] } }
    merge_candidates
  end

  def self.count_accents(string)
    # [[:alpha:]] will match accented characters, \w will not.
    (string.scan(/[[:alpha:]]/) - string.scan(/\w/)).size
  end

  MALE_FIRST_NAMES = Set.new(%w[Jannick Candido Loïc Patrick Raffael Kazim Luca Manuel Patrice Eric Yannick Emanuil Mathieu Nicolo] + ['Mirade Omeri'])
  FEMALE_FIRST_NAMES = Set.new(%w[Denise Esther Tabea Capucine Lucienne Inci Carole Dominique Yan])
  POSSIBLY_WRONGLY_ACCENTED_ATTRIBUTES = %i[first_name last_name].freeze
  POSSIBLY_WRONGLY_CASED_ATTRIBUTES = %i[club_or_hometown].freeze
  POSSIBLY_WRONGLY_SPACED_ATTRIBUTES = %i[first_name last_name club_or_hometown].freeze
  POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES = %i[first_name last_name club_or_hometown].freeze

  def merge_duplicates
    merge_duplicates_based_on_sex
    merge_duplicates_based_on_nationality
    merge_duplicates_based_on_accents
    merge_duplicates_based_on_case
    merge_duplicates_based_on_space
    merge_duplicates_based_on_umlaute
    merge_duplicates_based_on_msm_prefix
    merge_duplicates_based_on_hometown_prefix
  end

  # Handle wrong sex, try to find correct sex using name list.
  def merge_duplicates_based_on_sex
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
    puts "Merged #{merged_runners} entries based on sex." unless Rails.env.test?
  end

  def merge_duplicates_based_on_nationality
    merged_runners = 0
    find_runners_only_differing_in(:nationality).each do |entries|
      # Use most recent non-blank nationality.
      merged_runners += reduce_to_one_runner_by_condition(entries) do |e|
        if e.nationality.blank?
          Time.at(0) # Start of unix epoch to guarantee this is last.
        else
          e.run_days.max_by(&:date).date
        end
      end
    end
    puts "Merged #{merged_runners} entries based nationality" unless Rails.env.test?
  end

  def merge_duplicates_based_on_accents
    POSSIBLY_WRONGLY_ACCENTED_ATTRIBUTES.each do |attr|
      merged_runners = 0
      find_runners_only_differing_in(attr, ["f_unaccent(#{attr}) as unaccented"], ['unaccented']).each do |entries|
        # The correct entry is the one with more accents (probably?).
        merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
          self.class.count_accents(runner[attr])
        end
      end
      puts "Merged #{merged_runners} entries based on accents of #{attr}." unless Rails.env.test?
    end
  end

  # Try to fix case sensitive duplicates in club_or_hometown, e. g. in
  # Veronique Plessis Arc Et Senans
  # Veronique Plessis Arc et Senans
  def merge_duplicates_based_on_case
    POSSIBLY_WRONGLY_CASED_ATTRIBUTES.each do |attr|
      merged_runners = 0
      find_runners_only_differing_in(attr, ["f_unaccent(lower(#{attr})) as low"], ['low']).each do |entries|
        # We prefer the version with capital first letter and more lowercase
        # characters. E. g. for
        # Reichenbach I. K.
        # reichenbach i. K.
        # Reichenbach i. K.
        # the version at the bottom is preferred.
        merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
          [runner[attr][0] == runner[attr][0].upcase ? 1 : 0,
           runner[attr].scan(/[[:lower:]]/).size]
        end
      end
      puts "Merged #{merged_runners} entries based on case of #{attr}." unless Rails.env.test?
    end
  end

  def merge_duplicates_based_on_space
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
      puts "Merged #{merged_runners} entries based on spaces of #{attr}." unless Rails.env.test?
    end
  end

  def merge_duplicates_based_on_umlaute
    # Allow missing umlaut to be in any attribute (it may occur that it's missing in the last name and hometown).
    select_statement = POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES.each_with_index.map do |attr, idx|
      "replace(replace(replace(lower(#{attr}), 'ae', 'ä'), 'oe', 'ö'), 'ue', 'ü') as with_umlaut_#{idx}"
    end
    group_attributes = POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES.each_with_index.map { |_, idx| "with_umlaut_#{idx}" }

    merged_runners = 0
    find_runners_only_differing_in(POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES, select_statement,
                                   group_attributes, removed_attributes: [:nationality]).each do |entries|
      # assume the correct entry is the one with more Umlaute,
      # as there seemed to be no unicode support in earlier data.
      merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
        POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES.inject(0) { |sum, attr| sum + runner[attr].count('äüöÄÜÖ') }
      end
    end
    puts "Merged #{merged_runners} entries based on Umlaute in any of #{POSSIBLY_CONTAINING_UMLAUTE_ATTRIBUTES}" unless Rails.env.test?
  end

  # A runner might appear with two similar hometowns, e. g. once with 'Muri b. Bern' and once with 'Muri'.
  def merge_duplicates_based_on_hometown_prefix
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
    puts "Merged #{merged_runners} entries based on prefix of club or hometown" unless Rails.env.test?
  end

  # A runner might appear with two similar clubs,
  # e. g. once with 'MSM - BFE Berufsfachschule Emmental' and once with 'BFE Berufsfachschule Emmental'.
  def merge_duplicates_based_on_msm_prefix
    merged_runners = 0
    suffix_length = 4
    attribute = :club_or_hometown
    find_runners_only_differing_in(attribute, ["lower(replace(#{attribute},'MSM - ', '')) as no_msm_prefix"], ['no_msm_prefix']).each do |entries|
      # Pick the version including 'MSM' (is always the longer one).
      merged_runners += reduce_to_one_runner_by_condition(entries) do |runner|
        runner[:club_or_hometown].length
      end
    end
    puts "Merged #{merged_runners} entries based on prefix MSM prefix" unless Rails.env.test?
  end

  # A runner might appear with two similar clubs,
  # TODO: clean this up, e. g. by running on restricted corpus.
  # As it is now, it might merge 'Zollikofen' with 'Rennclub Zollikofen', which might not be the preferred behavior
  # (Since these are two different entities, unlike the other merges that just try to rectify typos/variation of writings of the same entity).
  # This kind of merge should probably only be done manually.
  def merge_duplicates_based_on_hometown_suffix
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
    puts "Merged #{merged_runners} entries based on prefix of club or hometown" unless Rails.env.test?
  end

  # Reduces the given entries to only one, chosen by the block passed.
  # The one that evaluates to the maximum of the block passed will be retained,
  # the others merged with it.
  def reduce_to_one_runner_by_condition(entries)
    correct_entry = entries.max_by { |entry| yield(entry) }
    # Return early if already associated with a merge runner request.
    return 0 if entries.any? { |e| !e.merge_runners_requests.empty? }

    request = MergeRunnersRequest.new_from(entries, correct_entry)
    if request.save
      request.approve! if @auto_approve
      entries.size - 1
    else
      0
    end
  end
end
