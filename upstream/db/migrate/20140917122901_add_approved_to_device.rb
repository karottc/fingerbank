class AddApprovedToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :approved, :boolean, :default => true
  end
end
