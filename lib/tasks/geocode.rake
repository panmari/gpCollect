# frozen_string_literal: true

require_relative 'geocoder'
require_relative 'club_or_hometown_normalizer'

namespace :geocode do
  GEOCODER = Geocoder.new(ENV['GOOGLE_API_KEY'],
                          'db/geocoding_data/ignored_prefixes.csv',
                          'db/geocoding_data/non_geocodable_club_or_hometown.csv')

  desc 'Create geocode results for runners that have geocode results missing'
  task create: :environment do
    # Clean up all non-geocodable results.
    d = GeocodeResult.where(address: GEOCODER.non_geocodable_club_or_hometowns)
                     .destroy_all
    puts "Deleted #{d.size} geocode results that were identified as non-geocodable."

    # Get non-geocoded raw addresses and process most often occurring ones first.
    Runner.where(geocode_result: nil)
          .where.not(club_or_hometown: nil)
          .group(:club_or_hometown).count
          .sort_by(&:second).reverse_each do |raw_address, _|
      address = GEOCODER.clean_address(raw_address)
      unless GEOCODER.valid_address?(address)
        # Delete association with previous geocoding result.
        Runner.where(club_or_hometown: raw_address)
              .update_all(geocode_result_id: nil)
        next
      end

      ActiveRecord::Base.transaction do
        geocode_result = GeocodeResult.find_by(address: address)
        unless geocode_result
          most_prominent_nationality = Runner.where(club_or_hometown: raw_address)
                                             .group(:nationality).count
                                             .max_by(&:second).first
          response = GEOCODER.geocode(address, most_prominent_nationality)
          geocode_result = GeocodeResult.create!(address: address,
                                                 response: response)
        end
        Runner.where(club_or_hometown: raw_address)
              .update_all(geocode_result_id: geocode_result.id)
      end
    end
  end

  desc 'Retries geocoding for all geocode results that are in the scope
  "failed". If the geocoding result\'s address is not valid, it is destroyed.'
  task retry: :environment do
    GeocodeResult.includes(:runners).failed.each do |gr|
      unless GEOCODER.valid_address?(gr.address)
        # Not a valid address, destroy this result.
        gr.destroy!
        next
      end
      most_prominent_nationality = gr.runners.group(:nationality).count
                                     .max_by(&:second).first
      response = GEOCODER.geocode(gr.address, most_prominent_nationality)
      gr.update_attributes!(response: response)
    end
  end

  desc 'Removes all geocode results and all associations to geocode results in
  runners. This might run for a long time!'
  task reset: :environment do
    Runner.update_all(geocode_result_id: nil)
    GeocodeResult.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('geocode_results')
  end

  desc 'Normalizes club_or_hometown for known cases to their canonical form.
  For example, maps \'Zuerich\' => \'Zürich\'. Will only replace if
  1. There is a pre-defined pattern for this substitution.
  2. The new name already occurs in the database.
  3. The substitutions are manually confirmed.'
  task normalize_club_or_hometown: :environment do
    towns_with_counts = Runner.group(:club_or_hometown).count
    normalizer = ClubOrHometownNormalizer.new(towns_with_counts.map(&:first))
    substitutions_candidates = towns_with_counts.each_with_object({}) do |town_with_count, h|
      town = town_with_count.first
      new_town = normalizer.normalize(town)
      next if town == new_town

      h[town_with_count] = new_town
    end
    puts substitutions_candidates
    puts 'Confirm updating substitution candidates [y/N]'
    unless STDIN.gets.chomp.casecmp('Y').zero?
      puts 'Missing confirmation for updating records, continuing..'
      next
    end
    updated_runners = 0
    substitutions_candidates.each do |old_with_count, new|
      updated_runners += Runner.where(club_or_hometown: old_with_count.first)
                               .update_all(club_or_hometown: new,
                                           geocode_result_id: nil)
    end
    puts "Updated club_or_hometown for #{updated_runners} runners, normalizing #{substitutions_candidates.size} instances."
  end
end
