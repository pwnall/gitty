class AddUserProfiles < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.references :profile, :null => true
    end
    add_index :users, :profile_id, :unique => true, :null => true
  end
end
