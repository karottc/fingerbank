class AddSubmitterIdToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :submitter_id, :integer
  end
end
