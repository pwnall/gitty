class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.references :user, :null => false
      t.string :type, :limit => 32, :null => false
      t.string :name, :limit => 128, :null => true

      t.boolean :verified, :null => false, :default => false
      t.timestamp :updated_at, :null => false

      t.binary :key, :limit => 2.kilobytes, :null => true
    end

    # All the credentials (maybe of a specific type) belonging to a user.
    add_index :credentials, [:user_id, :type], :unique => false,
                                               :null => false
    # A specific credential, to find out what user it belongs to.
    add_index :credentials, [:type, :name], :unique => true, :null => true
    # Expired credentials (particularly useful for tokens).
    add_index :credentials, [:type, :updated_at], :unique => false,
                                                  :null => false
  end
end
