class AddKeyToCondition < ActiveRecord::Migration
  def change
    add_column :conditions, :key, :string
  end
end
