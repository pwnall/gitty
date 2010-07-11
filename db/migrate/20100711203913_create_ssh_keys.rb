class CreateSshKeys < ActiveRecord::Migration
  def self.up
    create_table :ssh_keys do |t|
      t.string :fprint, :limit => 128, :null => false
      t.string :name, :limit => 128, :null => false
      t.text :key_line, :limit => 1.kilobyte, :null => false

      t.timestamps
    end    
    add_index :ssh_keys, :fprint, :unique => true, :null => false
  end

  def self.down
    drop_table :ssh_keys
  end
end
