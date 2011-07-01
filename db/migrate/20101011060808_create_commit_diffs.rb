class CreateCommitDiffs < ActiveRecord::Migration
  def change
    create_table :commit_diffs do |t|
      t.integer :commit_id, :null => false
      t.integer :old_blob_id, :null => true
      t.integer :new_blob_id, :null => true
      t.string :old_path, :null => true, :length => 1.kilobyte
      t.string :new_path, :null => true, :length => 1.kilobyte
    end
    add_index :commit_diffs, :commit_id, :unique => false, :null => false
  end
end
