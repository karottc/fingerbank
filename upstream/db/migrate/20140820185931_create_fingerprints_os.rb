class CreateFingerprintsOs < ActiveRecord::Migration
  def change
    create_table :fingerprints_os do |t|
      t.column :os_id, :integer
      t.column :fingerprint_id, :integer
    end
  end
end
