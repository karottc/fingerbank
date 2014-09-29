json.array!(@dhcp_fingerprints) do |dhcp_fingerprint|
  json.extract! dhcp_fingerprint, :id
  json.url dhcp_fingerprint_url(dhcp_fingerprint, format: :json)
end
