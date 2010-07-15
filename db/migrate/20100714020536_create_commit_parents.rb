class CreateCommitParents < ActiveRecord::Migration
  def self.up
    create_table :commit_parents do |t|
      t.integer :commit_id, :null => false
      t.integer :parent_id, :null => false
    end
    add_index :commit_parents, [:commit_id, :parent_id], :unique => true,
              :null => false
  end

  def self.down
    drop_table :commit_parents
  end
end
