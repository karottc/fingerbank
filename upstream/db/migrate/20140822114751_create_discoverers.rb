class CreateDiscoverers < ActiveRecord::Migration
  def change
    create_table :discoverers do |t|
      t.integer :os_id
      t.integer :os_rule_id
      t.integer :version_rule_id

      t.timestamps
    end
  end
end
