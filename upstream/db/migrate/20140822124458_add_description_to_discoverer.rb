class AddDescriptionToDiscoverer < ActiveRecord::Migration
  def change
    add_column :discoverers, :description, :string
  end
end
