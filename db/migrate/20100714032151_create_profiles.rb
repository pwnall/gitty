class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :name, :limit => 32, :null => false
      t.string :display_name, :limit => 128, :null => false

      t.timestamps
    end
    add_index :profiles, :name, :unique => true, :null => false
  end

  def self.down
    drop_table :profiles
  end
end
