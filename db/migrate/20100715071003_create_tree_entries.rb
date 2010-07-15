class CreateTreeEntries < ActiveRecord::Migration
  def self.up
    create_table :tree_entries do |t|
      t.integer :tree_id, :null => false
      t.string :child_type, :limit => 8, :null => false
      t.integer :child_id, :null => false
      t.string :name, :limit => 128, :null => false
    end
    add_index :tree_entries, [:tree_id, :child_type, :child_id],
              :null => false, :unique => true
    add_index :tree_entries, [:tree_id, :name], :null => false, :unique => true
  end

  def self.down
    drop_table :tree_entries
  end
end
