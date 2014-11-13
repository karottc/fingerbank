class MakeValuesBigger < ActiveRecord::Migration
  def change
    change_column :user_agents, :value, :string, :limit => 1000
    change_column :dhcp_fingerprints, :value, :string, :limit => 1000
    change_column :dhcp_vendors, :value, :string, :limit => 1000
  end
end
