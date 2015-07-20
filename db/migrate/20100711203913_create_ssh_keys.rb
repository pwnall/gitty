class CreateSshKeys < ActiveRecord::Migration
  def change
    create_table :ssh_keys do |t|
      t.string :fprint, :limit => 128, :null => false
      t.integer :user_id, :null => false
      t.string :name, :limit => 128, :null => false
      t.text :key_line, :limit => 1.kilobyte, :null => false

      t.timestamps :null => false
    end
    add_index :ssh_keys, :fprint, :unique => true
    add_index :ssh_keys, :user_id, :unique => false
  end
end
