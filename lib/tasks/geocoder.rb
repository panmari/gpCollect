# frozen_string_literal: true

require 'net/http'
require 'json'

# Helper class for geocoding entities using the Google geocoding API.
# For quota available, see https://console.developers.google.com/apis/api/geocoding-backend.googleapis.com/quotas.
# Expects 'GOOGLE_API_KEY' set in the environment.
class Geocoder
  def initialize(ignored_prefixes_file, non_geocodable_club_or_hometown_file)
    @ignored_prefixes_regex = File.open(ignored_prefixes_file) do |f|
      /^(#{f.readlines.map { |p| Regexp.escape(p.strip) }.join('|')})[ -]+/
    end
    @non_geocodable_club_or_hometowns = File.open(non_geocodable_club_or_hometown_file) do |f|
      f.each_with_object(Set.new) { |l, a| a << l.strip }
    end
  end

  def clean_address(address)
    s = address.gsub('bei /B.', 'bei Burgdorf')
    s.gsub!('Deisswil Mbuchsee', 'Deisswil bei Münchenbuchsee')
    s.gsub!('Bärn', 'Bern')
    s.gsub!('Berm', 'Bern')
    s.gsub!(@ignored_prefixes_regex, '')
    # TODO: Harden for strings that only consist of '//////' or '/ asdf' (currently throws exception).
    s = s.split('/')[0].strip
    s
  end

  def valid_address?(address)
    return false if @non_geocodable_club_or_hometowns.include?(address)

    !address.blank? &&
      address.length >= 2 &&
      address.length < 40 && # Very long things are usually full sentences.
      !/\.(ch|de)$/.match(address) && # Swiss domain ending, eg freizeit.ch.
      !/^[A-Z]{1,3}$/.match(address) # Nationality-only string.
    # TODO(panmari):If club or hometown contains numbers, chances are high that it's a club and not geolocatable.
  end

  # Geocodes the given address by making a call to the Google Maps geocoding API.
  def geocode(address, nationality)
    response = JSON.parse(Net::HTTP.get(to_uri(address, nationality)),
                          symbolize_names: true)
    raise 'Over query limit' if response[:status] == 'OVER_QUERY_LIMIT'

    response
  end

  private

  def to_uri(address, nationality)
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape(address)}&key=#{ENV['GOOGLE_API_KEY']}"
    region = NATIONALITY_TO_REGION[nationality] || 'ch'
    url += '&region=' + region
    URI(url)
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
                            'DEN' => 'dk', # Also denmark, additionally to DNK.
                            'LIB' => 'lr', # TODO: Liberia (lr) or Libya (ly)
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
