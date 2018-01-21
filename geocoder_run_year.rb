require 'ruby-progressbar'
load 'geocoder.rb'

year = 2015
geocoder_cache_file = 'geocoder_cache.json'
geocoder = Geocoder.new(geocoder_cache_file,
                        'ags.list',
                        'ignored_prefixes.list',
                        retry_failures: false)
lat_long_weights = Hash.new(0)
f = File.open('failures_with_count.log', 'w')
begin
  keyed_counts = RunDay.find_by_year!(year).runners.group(:club_or_hometown, :nationality).count
  pg = ProgressBar.create(title: 'Geocoding queries', total: keyed_counts.size)
  keyed_counts.sort_by(&:second).reverse.map(&:flatten).each do |place, nationality, count|
    lat_lng, = geocoder.find_lat_long_for(place, nationality)
    if lat_lng.blank?
      f.puts(place, count)
    else
      lat_long_weights[lat_lng] += count
    end
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
  pg.finish
  puts("Geocoded #{lat_long_weights.values.sum} of #{keyed_counts.values.sum} runners")
end
