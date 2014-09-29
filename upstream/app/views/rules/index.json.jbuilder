json.array!(@rules) do |rule|
  json.extract! rule, :id, :value, :device_id
  json.url rule_url(rule, format: :json)
end
