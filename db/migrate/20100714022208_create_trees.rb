class CreateTrees < ActiveRecord::Migration
  def self.up
    create_table :trees do |t|
      t.integer :repository_id
      t.string :gitid, :limit => 64, :null => false
    end
    add_index :trees, [:repository_id, :gitid], :unique => true, :null => false
  end

  def self.down
    drop_table :trees
  end
end
