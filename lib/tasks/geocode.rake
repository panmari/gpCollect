# frozen_string_literal: true

require_relative 'geocoder'

namespace :db do
  desc 'Create geocode results for runners that have geocode results missing'
  task geocode: :environment do
    geocoder = Geocoder.new('db/data/ignored_prefixes.csv',
                            'db/data/non_geocodable_club_or_hometown.csv')
    # Get non-geocoded raw addresses and process most often occurring ones first.
    Runner.where(geocode_result: nil)
          .where.not(club_or_hometown: nil)
          .group(:club_or_hometown).count
          .sort_by(&:second).reverse_each do |raw_address, _|
      address = geocoder.clean_address(raw_address)
      unless geocoder.valid_address?(address)
        # Delete association with previous geocoding result.
        Runner.where(club_or_hometown: raw_address)
              .update_all(geocode_result_id: nil)
        next
      end

      geocode_result = GeocodeResult.find_by_address(address)
      unless geocode_result
        most_prominent_nationality = Runner.where(club_or_hometown: raw_address)
                                           .group(:nationality).count
                                           .max_by(&:second).first
        response = geocoder.geocode(address, most_prominent_nationality)
        geocode_result = GeocodeResult.create!(address: address,
                                               response: response)
      end
      Runner.where(club_or_hometown: raw_address).update_all(geocode_result_id: geocode_result.id)
    end
  end

  desc 'Normalizes club_or_hometown for known cases to their canonical form.
  For example, maps \'Zuerich\' => \'Zürich\'. Will only replace if
  1. There is a pre-defined pattern for this substitution.
  2. The new name already occurs in the database.
  3. The substitutions are manually confirmed.'
  task normalize_club_or_hometown: :environment do
    substitution_patterns = { /ae/ => 'ä', /ue/ => 'ü', /oe/ => 'ö',
                              /[Gg]eneve/ => 'Genève', /Glane/i => 'Glâne',
                              /(Thun)/i => ' (Thun)',
                              /Lützelflüh-Goldb/i => 'Lützelflüh-Goldbach',
                              /St[. ]( )*/i => 'St. ',
                              /-s-/i => '-sur-', # e.g. Romanel-sur-Lausanne
                              / im /i => ' im ', # Im Emmental => im Emmental.
                              / ob /i => ' ob ', # Ob Gunten => ob Gunten.
                              / im Kande\z/i => ' im Kandertal',
                              / bei Aad\z/i => ' bei Aadorf',
                              / bei Kall(na)?/i => ' bei Kalnach',
                              /Hasle bei \/?B\./i => 'Hasle bei Burgdorf',
                              / a\/Albis/i => 'am Albis',
                              /Hindelb\z/i => 'Hindelbank',
                              /im Emmen?t?a?/i => 'im Emmental',
                              /I\. ?E\.\z/i => 'im Emmental',
                              # 'an der Aare' uses similar patterns, making it
                              # hard to make this more generic.
                              /(?<=Affoltern|Langnau|Hausen|Kappel) A[.m]? ?A(\.|(lbis))\z/ => ' am Albis',
                              / (b\.|bei) /i => ' bei ' }
    %w[BE FR GL NW SO SG VD ZH].each do |canton|
      substitution_patterns[/( \/)? \(?#{canton}\)?\z/i] = " #{canton}"
    end
    towns = Runner.group(:club_or_hometown).count
                  .sort_by(&:second).reverse.map(&:first)
    substitutions_candidates = towns.each_with_object({}) do |town, h|
      next if town.nil?
      next unless substitution_patterns.any? { |before, _| before.match(town) }

      new_town = +town # Fancy syntax to return mutable copy of frozen string.
      substitution_patterns.each do |before, after|
        new_town.gsub!(before, after)
      end
      next if town == new_town
      next unless towns.include?(new_town)

      h[town] = new_town
    end
    puts substitutions_candidates
    puts 'Confirm updating substitution candidates [y/N]'
    unless STDIN.gets.chomp.casecmp('Y').zero?
      puts 'Missing confirmation for updating records, continuing..'
      next
    end
    updated_runners = 0
    substitutions_candidates.each do |old, new|
      updated_runners += Runner.where(club_or_hometown: old)
                               .update_all(club_or_hometown: new)
    end
    puts "Updated club_or_hometown for #{update_runners} runners, normalizing #{substitutions_candidates.size} instances."
  end
end
