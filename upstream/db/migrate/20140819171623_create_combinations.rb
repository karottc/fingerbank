class CreateCombinations < ActiveRecord::Migration
  def change
    create_table :combinations do |t|
      t.integer :fingerprint_id
      t.integer :user_agent_id

      t.timestamps
    end
  end
end
