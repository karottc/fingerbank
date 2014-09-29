class RenameDhcpFingerprints < ActiveRecord::Migration
  def change
    rename_table :dhcp_fingerprints, :dhcp_dhcp_fingerprints
  end
end
