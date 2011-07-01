class CreateFacebookTokens < ActiveRecord::Migration
  def change
    create_table :facebook_tokens do |t|
      t.integer :user_id, :null => false
      t.string :external_uid, :limit => 32, :null => false
      t.string :access_token, :limit => 128, :null => false
    end
    
    add_index :facebook_tokens, :external_uid, :unique => true, :null => false
  end
end
