class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email, :limit => 128, :null => false
      t.string :email_hash, :limit => 64, :null => false
      t.string :password_salt, :limit => 16, :null => true
      t.string :password_hash, :limit => 64, :null => true
      
      t.timestamps
    end
    
    add_index :users, :email, :unique => true, :null => false
    add_index :users, :email_hash, :unique => true, :null => false
  end

  def self.down
    drop_table :users
  end
end
