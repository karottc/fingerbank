class AddMacVendorIdToCombination < ActiveRecord::Migration
  def change
    add_column :combinations, :mac_vendor_id, :integer
  end
end
