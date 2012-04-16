class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.references :repository, :null  => false
      t.references :author, :null => false
      t.boolean :open, :default => true, :null => false
      t.boolean :sensitive, :default => false, :null => false
      t.string :title, :length => 160, :null => false
      t.text :description, :length => 1.kilobyte, :null => false

      t.timestamps
    end
    
    add_index :issues, [:author_id, :open], :unique => false, :null => false
    add_index :issues, [:repository_id, :open], :unique => false, :null => false
  end
end
