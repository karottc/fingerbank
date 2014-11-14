class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :github_uid, :null => false
      t.string :name, :null => false
      t.string :display_name
      t.integer :level, :default => 0

      t.timestamps
    end
  end
end
