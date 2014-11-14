json.array!(@device) do |o|
  json.extract! o, :id
  json.url o_url(o, format: :json)
end
