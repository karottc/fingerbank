class AddScoreToCombination < ActiveRecord::Migration
  def change
    add_column :combinations, :score, :integer, :default => 0
  end
end
