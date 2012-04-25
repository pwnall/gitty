class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.references :repository, :null  => false
      t.references :author, :null => false
      t.boolean :open, :default => true, :null => false
      t.boolean :sensitive, :default => false, :null => false
      t.string :title, :limit => 160, :null => false
      t.text :description, :limit => 1.kilobyte, :null => false
      t.integer :exid, :limit => 1..32, :null => false

      t.timestamps
    end
    
    add_index :issues, [:author_id, :open], :unique => false, :null => false
    add_index :issues, [:repository_id, :open], :unique => false, :null => false
    add_index :issues, [:repository_id, :exid], :unique => true, 
        :null => false
  end
end
