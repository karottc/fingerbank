class AddSubmitterToCombination < ActiveRecord::Migration
  def change
    add_column :combinations, :submitter_id, :integer
  end
end
