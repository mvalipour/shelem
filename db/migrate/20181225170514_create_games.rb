class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :uid, null: false, index: { unique: true }
      t.string :admin_uid
      t.string :location
      t.string :participants_blob
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
