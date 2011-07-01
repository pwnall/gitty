class CreateAclEntries < ActiveRecord::Migration
  def change
    create_table :acl_entries do |t|
      t.string :role, :length => 16, :null => false
      t.integer :subject_id, :null => false
      t.string :subject_type, :null => false, :length => 16
      t.integer :principal_id, :null => false
      t.string :principal_type, :null => false, :length => 16
      t.timestamps
    end
    
    add_index :acl_entries, [:principal_id, :principal_type, :subject_id,
        :subject_type], :null => false, :unique => true,
        :name => :index_acl_entries_by_principal_subject
    add_index :acl_entries, [:subject_id, :subject_type, :principal_id,
        :principal_type], :null => false, :unique => true,
        :name => :index_acl_entries_by_subject_principal
  end
end
