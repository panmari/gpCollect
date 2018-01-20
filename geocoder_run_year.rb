require 'ruby-progressbar'
load 'geocoder.rb'

year = 2017
geocoder_cache_file = 'geocoder_cache.json'
geocoder = Geocoder.new(geocoder_cache_file,
                        'ags.list',
                        'ignored_prefixes.list',
                        retry_failures: true)
lat_long_weights = Hash.new(0)

begin
  keyed_counts = RunDay.find_by_year!(year).runners.group(:club_or_hometown, :nationality).count
  pg = ProgressBar.create(title: 'Geocoding queries', total: keyed_counts.size)
  keyed_counts.each do |key, count|
    lat_long, place = geocoder.find_lat_long_for(key[0], key[1])
    lat_long_weights[lat_long] += count unless lat_long.blank?
    pg.increment
  end
rescue StandardError => e
  puts 'Failed at some point: ' + e.message
  puts e.backtrace.join("\n")
ensure
  geocoder.dump_cache(geocoder_cache_file)
  File.open("lat_long_weights_#{year}.json", 'w') do |f|
    f.write(lat_long_weights.sort_by(&:second).reverse.to_json)
  end
end
