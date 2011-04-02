class AddEmailHashToUsers < ActiveRecord::Migration
  def self.up
    return
    add_column :users, :email_hash, :string, :limit => 64

    User.all.each do |user|
      user.email = user.email
      user.save!
    end

    change_column :users, :email_hash, :string, :limit => 64, :null => false
    add_index :users, :email_hash, :null => false, :unique => true
  end

  def self.down
    remove_column :users, :email_hash
  end
end
