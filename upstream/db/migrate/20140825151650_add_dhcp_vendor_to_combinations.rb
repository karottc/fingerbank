class AddDhcpVendorToCombinations < ActiveRecord::Migration
  def change
    add_column :combinations, :dhcp_vendor_id, :integer
  end
end
