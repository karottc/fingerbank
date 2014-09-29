class CreateOs < ActiveRecord::Migration
  def change
    create_table :os do |t|
      t.string :name
      t.boolean :mobile
      t.boolean :tablet

      t.timestamps
    end
  end
end
