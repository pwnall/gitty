class CreateTreeEntries < ActiveRecord::Migration
  def change
    create_table :tree_entries do |t|
      t.integer :tree_id, :null => false
      t.string :child_type, :limit => 16, :null => false
      t.integer :child_id, :null => false
      t.string :name, :limit => 128, :null => false
    end
    add_index :tree_entries, [:tree_id, :name], :null => false, :unique => true
  end
end
