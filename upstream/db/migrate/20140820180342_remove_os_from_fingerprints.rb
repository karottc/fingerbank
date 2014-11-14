class RemoveOsFromFingerprints < ActiveRecord::Migration
  def change
    remove_column :fingerprints, :os_id
  end
end
