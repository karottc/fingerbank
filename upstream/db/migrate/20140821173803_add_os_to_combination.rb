class AddOsToCombination < ActiveRecord::Migration
  def change
    add_column :combinations, :os_id, :integer
  end
end
