class CreateCommitParents < ActiveRecord::Migration
  def change
    create_table :commit_parents do |t|
      t.integer :commit_id, :null => false
      t.integer :parent_id, :null => false
    end
    add_index :commit_parents, [:commit_id, :parent_id], :unique => true,
              :null => false
  end
end
