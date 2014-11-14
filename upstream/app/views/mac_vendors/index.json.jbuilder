json.array!(@mac_vendors) do |mac_vendor|
  json.extract! mac_vendor, :id, :name, :mac
  json.url mac_vendor_url(mac_vendor, format: :json)
end
