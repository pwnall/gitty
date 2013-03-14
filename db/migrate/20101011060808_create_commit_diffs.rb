class CreateCommitDiffs < ActiveRecord::Migration
  def change
    create_table :commit_diffs do |t|
      t.integer :commit_id, :null => false
      t.integer :old_object_id, :null => true
      t.string :old_object_type, :limit => 16, :null => true
      t.integer :new_object_id, :null => true
      t.string :new_object_type, :limit => 16, :null => true
      t.string :old_path, :null => true, :length => 1.kilobyte
      t.string :new_path, :null => true, :length => 1.kilobyte
    end
    add_index :commit_diffs, :commit_id, :unique => false
  end
end
