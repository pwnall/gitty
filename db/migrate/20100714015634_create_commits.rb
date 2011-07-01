class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.integer :repository_id, :null => false
      t.string :gitid, :limit => 64, :null => false

      t.integer :tree_id, :null => false
      t.string :author_name, :limit => 128, :null => false
      t.string :author_email, :limit => 128, :null => false
      t.string :committer_name, :limit => 128, :null => false
      t.string :committer_email, :limit => 128, :null => false
      t.datetime :authored_at, :null => false
      t.datetime :committed_at, :null => false
      
      t.text :message, :limit => 1.kilobyte, :null => false
    end
    add_index :commits, [:repository_id, :gitid], :unique => true,
              :null => false
  end
end
