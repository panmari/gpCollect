module ChartHelpers
  def date_to_miliseconds(date)
    date.to_time.to_i * 1000
  end

  ### Copied private helpers from lazy_high_charts/lib/lazy_high_charts/layout_helper.rb
  def generate_json_from_value(value)
    if value.is_a? Hash
      %({ #{generate_json_from_hash value} })
    elsif value.is_a? Array
      %([ #{generate_json_from_array value} ])
    elsif value.respond_to?(:js_code) && value.js_code?
      value
    else
      value.to_json
    end
  end
end
