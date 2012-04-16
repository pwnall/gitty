class CreateBlobs < ActiveRecord::Migration
  def change
    create_table :blobs do |t|
      t.integer :repository_id, :null => false
      t.integer :size, :null => false
      t.string :gitid, :limit => 64, :null => false
      t.string :mime_type, :limit => 256, :null => false
    end
    add_index :blobs, [:repository_id, :gitid], :unique => true, :null => false
  end
end
