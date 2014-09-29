class AddSelfRefToOs < ActiveRecord::Migration
  def change
    add_column :os, :parent_id, :integer
  end
end
