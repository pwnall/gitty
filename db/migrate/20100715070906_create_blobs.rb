class CreateBlobs < ActiveRecord::Migration
  def self.up
    create_table :blobs do |t|
      t.integer :repository_id, :null => false
      t.string :gitid, :limit => 64, :null => false
    end
    add_index :blobs, [:repository_id, :gitid], :unique => true, :null => false
  end

  def self.down
    drop_table :blobs
  end
end
