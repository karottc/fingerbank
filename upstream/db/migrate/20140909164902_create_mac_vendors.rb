class CreateMacVendors < ActiveRecord::Migration
  def change
    create_table :mac_vendors do |t|
      t.string :name
      t.string :mac

      t.timestamps
    end
    add_index :mac_vendors, :mac, :unique => true
  end
end
