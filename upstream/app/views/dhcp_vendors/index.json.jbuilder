json.array!(@dhcp_vendors) do |dhcp_vendor|
  json.extract! dhcp_vendor, :id, :value
  json.url dhcp_vendor_url(dhcp_vendor, format: :json)
end
