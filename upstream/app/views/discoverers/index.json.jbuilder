json.array!(@discoverers) do |discoverer|
  json.extract! discoverer, :id
  json.url discoverer_url(discoverer, format: :json)
end
