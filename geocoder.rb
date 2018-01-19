require 'net/http'
require 'pp'
require 'json'

class Geocoder
  def initialize(cache_file, ags_file, ignored_prefixes_file)
    @api_key = ENV['GOOGLE_API_KEY']
    @cache = if cache_file
               JSON.parse(File.open(cache_file).read)
             else
               {}
             end
    @error_log = File.open('geocoder_err.log', 'w')
    @ignored_prefixes_regex = File.open(ignored_prefixes_file) { |f| /^(#{f.map { |p| Regexp.escape(p) }.join('|')}) / }
    @club_names = File.open(ags_file) { |f| f.each_with_object(Set.new) { |l, a| a << l.strip.downcase } }
  end

  def dump_cache(cache_file)
    @error_log.close
    File.open(cache_file, 'w') do |f|
      f.write(@cache.to_json)
    end
  end

  def find_lat_long_for(runner)
    if runner.club_or_hometown.blank? || /\d/.match(runner.club_or_hometown) ||
       /^[A-Z]{1,3}$/.match(runner.club_or_hometown) || @club_names.include?(runner.club_or_hometown.downcase)
      # If club or hometown contains numbers, chances are high that it's a club and not geolocatable.
      return nil, "Blacklisted: #{runner.club_or_hometown}"
    end

    cleaned_hometown = runner.club_or_hometown.gsub(/I\. ?E\.\z/i, 'im Emmental')
    cleaned_hometown = cleaned_hometown.split('/')[0].strip
    cleaned_hometown.gsub!(/ b\. /i, ' bei ')
    cleaned_hometown.gsub!(/Hindelb\z/, 'Hindelbank')
    cleaned_hometown.gsub!(@ignored_prefixes_regex, '')

    cache_key = "#{cleaned_hometown}:#{runner.nationality}"
    if @cache[cache_key]
      return @cache[cache_key], "Cache hit for: #{cleaned_hometown}"
    end
    if @cache[cache_key] == false
      # TODO: Add option that retries failures.
      return nil, "Fail cache hit for: #{cleaned_hometown}"
    end
    uri = to_uri(cleaned_hometown, runner.nationality)

    response = JSON.parse(Net::HTTP.get(uri), symbolize_names: :true)

    unless response[:status] == 'OK'
      PP.pp('Google api returned status: ' + response[:status], @error_log)
      PP.pp(runner, @error_log)
      PP.pp(response, @error_log)
      if response[:status] == 'OVER_QUERY_LIMIT'
        raise Exception('Over query limit')
      end
      @cache[cache_key] = false
      return nil, cleaned_hometown
    end

    if (response[:results].size > 1) &&
       # Accept first result if it's formatted address consists of 'hometown, postcode'
       !/#{runner.club_or_hometown}, \d+,/.match(response[:results][0][:formatted_address])
      # TODO: Add check for distance of results, use first if all close to each other.
      PP.pp('More than one top results', @error_log)
      PP.pp(runner, @error_log)
      PP.pp(response, @error_log)
      @cache[cache_key] = false
      return nil, cleaned_hometown
    end

    geometry = response[:results][0][:geometry]
    @cache[cache_key] = geometry[:location]
    [geometry[:location], cleaned_hometown]
  end

  def to_uri(address, nationality)
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape(address)}&key=#{@api_key}"
    region = NATIONALITY_TO_REGION[nationality]
    url += "&region=#{region}" unless region.blank?
    URI(url)
  end

  def self.distance(loc1, loc2)
    rad_per_deg = Math::PI / 180 # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[:lat] - loc1[:lat]) * rad_per_deg # Delta, converted to rad
    dlon_rad = (loc2[:lng] - loc1[:lng]) * rad_per_deg

    lat1_rad, = loc1.values.map { |i| i * rad_per_deg }
    lat2_rad, = loc2.values.map { |i| i * rad_per_deg }

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    rm * c # Delta in meters
  end

  NATIONALITY_TO_REGION = { 'SUI' => 'ch',
                            'NEP' => 'np',
                            'HMD' => 'hm',
                            'SGS' => 'gs',
                            'ITA' => 'it',
                            'GUA' => 'gt', # Guatemala?
                            'PAN' => 'pa',
                            'ROM' => 'ro', # Romania?
                            'HUN' => 'hu',
                            'ECU' => 'ec',
                            'VAT' => 'va', # vatican - dafuq?
                            'COL' => 'co',
                            'BUL' => 'bg', # Bulgaria?
                            'KEN' => 'ke',
                            'LIE' => 'li',
                            'PUR' => '',
                            'CAN' => 'ca',
                            'VEN' => 've',
                            'DOM' => 'do',
                            'MDA' => 'md',
                            'AUT' => 'at',
                            'CHA' => 'td', # chad?,
                            'TUN' => 'tn',
                            'RSA' => '',
                            'MKD' => 'mk',
                            'AFG' => 'af',
                            'UKR' => 'ua',
                            'GHA' => 'gh',
                            'SRB' => 'rs',
                            'EST' => 'ee',
                            'IRI' => '',
                            'BRA' => 'br',
                            'DEN' => 'dk', # Not Denmark, since DNK is used below?
                            'LIB' => 'lr', # TODO: Liberia (LR) or Libya (LY)
                            'CHN' => 'cn',
                            'AHO' => '',
                            'ALB' => 'al',
                            'NCA' => '',
                            'CMR' => 'cm',
                            'CRI' => 'cr',
                            'SCG' => '',
                            'EGY' => 'eg',
                            'MAS' => '',
                            'POL' => 'pl',
                            'LTU' => 'lt',
                            'MEX' => 'mx',
                            'MRI' => '',
                            'LAT' => 'lv',
                            'ROU' => 'ro',
                            'VIE' => 'vn',
                            'HRV' => 'hr',
                            'IND' => 'in',
                            'INA' => '', # indonesia maybe?
                            'HKG' => 'hk',
                            'PER' => 'pe',
                            'AUS' => 'au',
                            'GRE' => 'gr',
                            'USA' => 'us',
                            'IVB' => '',
                            'POR' => 'pt',
                            'DNK' => 'dk',
                            'ISL' => 'is',
                            'RUS' => 'ru',
                            'THA' => 'th',
                            'GBR' => 'gb',
                            'NOR' => 'no',
                            'LUX' => 'lu',
                            'ESP' => 'es',
                            'CRC' => '',
                            'IRL' => 'ie',
                            'ERI' => 'er',
                            'GAM' => 'gm', # Gambia?
                            'TUR' => 'tr',
                            'FIN' => 'fi',
                            'UMI' => 'um',
                            'COD' => 'cd',
                            'SEN' => 'sn',
                            'NAM' => 'na',
                            'ISV' => '',
                            'JPN' => 'jp',
                            'ETH' => 'et',
                            'MAD' => 'mg', # Madagascar?
                            'BIH' => 'ba',
                            'SIN' => 'sg', # Singapore?
                            'FRA' => 'fr',
                            'MLT' => 'mt',
                            'MGL' => '',
                            'ALG' => 'dz', # Algeria?
                            'GER' => 'de',
                            'CUB' => 'cu',
                            'AND' => 'ad',
                            'ANG' => 'ao', # Angola?
                            'ESA' => '',
                            'BEL' => 'be',
                            'BOL' => 'bo',
                            'WLS' => '',
                            'SLO' => 'si', # Slovakia (sk) or Slovenia (si)?
                            'CRO' => 'hr',
                            'SVK' => 'sk',
                            'PHI' => 'ph',
                            'ARG' => 'ar',
                            'ZAM' => 'zm',
                            'MAR' => 'ma',
                            'CAF' => 'cf',
                            'NZL' => 'nz',
                            'NRU' => 'nr',
                            'CZE' => 'cz',
                            'SRI' => 'lk', # Sri Lanka?
                            'PAR' => 'py', # Paraguy?
                            'CHI' => 'cl', # Chile?
                            'KOR' => 'kr',
                            'NIG' => 'ng', # Nigeria (ng) or Niger (ne)?
                            'SF' => '', # Two letters? Wat?
                            'NED' => 'nl', # Netherlands?
                            'ISR' => 'il',
                            'SCO' => '',
                            'TPE' => '',
                            'SWE' => 'se' }.freeze
end
