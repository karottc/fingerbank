class AddVersionToCombination < ActiveRecord::Migration
  def change
    add_column :combinations, :version, :string
  end
end
