class RenameOsToDevices < ActiveRecord::Migration
  def change
    rename_table :os, :devices
  end
end
