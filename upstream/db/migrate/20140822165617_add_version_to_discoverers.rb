class AddVersionToDiscoverers < ActiveRecord::Migration
  def change
    add_column :discoverers, :version, :string
  end
end
