class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name, :limit => 32, :null => false
      t.string :display_name, :limit => 128, :null => false
      t.string :display_email, :limit => 128, :null => true

      t.timestamps
    end
    add_index :profiles, :name, :unique => true, :null => false
  end
end
