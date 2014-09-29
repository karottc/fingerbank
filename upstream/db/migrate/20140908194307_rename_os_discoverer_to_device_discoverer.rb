class RenameOsDiscovererToDeviceDiscoverer < ActiveRecord::Migration
  def change
    rename_column :discoverers, :os_rule_id, :device_rule_id
    rename_column :rules, :os_discoverer_id, :device_discoverer_id
  end
end
