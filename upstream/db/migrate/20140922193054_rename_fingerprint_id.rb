class RenameFingerprintId < ActiveRecord::Migration
  def change
    rename_column :combinations, :fingerprint_id, :dhcp_fingerprint_id
  end
end
