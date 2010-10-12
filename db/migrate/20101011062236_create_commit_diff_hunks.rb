class CreateCommitDiffHunks < ActiveRecord::Migration
  def self.up
    create_table :commit_diff_hunks do |t|
      t.integer :diff_id, :null => false
      t.integer :old_start, :null => false
      t.integer :old_count, :null => false
      t.integer :new_start, :null => false
      t.integer :new_count, :null => false
      t.text :context, :null => true, :length => 1.kilobyte
      t.text :summary, :null => true, :length => 32.kilobytes
    end
    add_index :commit_diff_hunks, :diff_id, :unique => false, :null => false
    add_index :commit_diff_hunks, [:diff_id, :old_start, :new_start],
              :unique => true, :null => false
  end

  def self.down
    drop_table :commit_diff_hunks
  end
end
