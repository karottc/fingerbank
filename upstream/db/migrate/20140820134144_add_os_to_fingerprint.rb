class AddOsToFingerprint < ActiveRecord::Migration
  def change
    add_column :fingerprints, :os_id, :integer
  end
end
