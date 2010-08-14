class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name, :limit => 128, :null => false
      t.integer :repository_id, :null => false
      t.integer :commit_id, :null => false
      t.string :committer_name, :limit => 128, :null => false
      t.string :committer_email, :limit => 128, :null => false
      t.datetime :committed_at, :null => false

      t.text :message, :limit => 2.kilobytes, :null => false
    end
    add_index :tags, [:repository_id, :name], :unique => true, :null => false
  end

  def self.down
    drop_table :tags
  end
end
