class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string :value
      t.integer :os_id

      t.timestamps
    end
  end
end
