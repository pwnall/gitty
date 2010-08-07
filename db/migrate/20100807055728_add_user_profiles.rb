class AddUserProfiles < ActiveRecord::Migration
  def self.up
    add_column :users, :profile_id, :integer, :null => true
    add_index :users, :profile_id, :unique => true, :null => true
  end

  def self.down    
    remove_column :users, :profile_id
  end
end
