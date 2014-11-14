class RefactorRules < ActiveRecord::Migration
  def change
    remove_column :rules, :os_id
    add_column :rules, :os_discoverer_id, :integer
    add_column :rules, :version_discoverer_id, :integer
  end
end
