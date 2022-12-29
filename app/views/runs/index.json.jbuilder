# frozen_string_literal: true

json.array!(@runs) do |run|
  json.extract! run, :id, :start, :duration, :runner_id
  json.url run_url(run, format: :json)
end
