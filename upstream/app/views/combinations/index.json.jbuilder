json.array!(@combinations) do |combination|
  json.extract! combination, :id, :user_agent_id, :dhcp_fingerprint_id
  json.url combination_url(combination, format: :json)
end
