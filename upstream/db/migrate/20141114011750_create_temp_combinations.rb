class CreateTempCombinations < ActiveRecord::Migration
  def change
    create_table :temp_combinations do |t|
      t.string :dhcp_fingerprint, :limit => 1000 
      t.string :user_agent, :limit => 1000 
      t.string :dhcp_vendor, :limit => 1000 
      t.timestamps
    end
  end
end
