require 'ruby-progressbar'
load 'geocoder.rb'

geocoder_cache_file = "geocoder_cache.json"
geocoder = Geocoder.new(geocoder_cache_file, 'ags.list')
lat_long_weights = Hash.new(0)
begin
  RunDay.last.runners.each do |runner|
    lat_long, place = geocoder.find_lat_long_for(runner)
    if lat_long.blank?
      puts "Fail: #{place}"
    else
      puts "Success: #{place}"
      lat_long_weights[lat_long] += 1
    end
  end
rescue Exception => e
  puts 'Failed at some point: ' + e.message
  puts e.backtrace.join("\n")
ensure
  geocoder.dump_cache(geocoder_cache_file)
  File.open("lat_long_weights.json", "w") do |f|
    f.write(lat_long_weights.to_json)
  end
end

