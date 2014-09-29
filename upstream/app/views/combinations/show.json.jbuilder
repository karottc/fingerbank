json.(@combination, :id, :version, :created_at, :updated_at)
if @combination.device
  json.device @combination.device, :id, :name, :mobile?, :created_at, :updated_at, :parent_id, :inherit, :parents
end
