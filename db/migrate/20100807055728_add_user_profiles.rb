class AddUserProfiles < ActiveRecord::Migration
  def change
    add_column :users, :profile_id, :integer, :null => true
    add_index :users, :profile_id, :unique => true, :null => true
  end
end
