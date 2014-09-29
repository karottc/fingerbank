class AddInheritToOs < ActiveRecord::Migration
  def change
    add_column :os, :inherit, :boolean
  end
end
