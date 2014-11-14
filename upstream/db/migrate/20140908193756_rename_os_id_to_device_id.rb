class RenameOsIdToDeviceId < ActiveRecord::Migration
  def change
    rename_column :combinations, :os_id, :device_id
    rename_column :discoverers, :os_id, :device_id
    rename_column :fingerprints_os, :os_id, :device_id
  end
end
