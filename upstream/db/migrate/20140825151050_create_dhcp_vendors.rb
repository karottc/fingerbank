class CreateDhcpVendors < ActiveRecord::Migration
  def change
    create_table :dhcp_vendors do |t|
      t.string :value

      t.timestamps
    end
  end
end
