class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|
      t.string :value
      t.integer :rule_id

      t.timestamps
    end
  end
end
