class AddPriorityToDiscoverers < ActiveRecord::Migration
  def change
    add_column :discoverers, :priority, :integer
  end
end
