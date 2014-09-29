class AddApiAccountingToUser < ActiveRecord::Migration
  def change
    add_column :users, :key, :string
    add_column :users, :requests, :integer, :default => 0
  end
end
