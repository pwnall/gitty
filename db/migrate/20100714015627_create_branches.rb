class CreateBranches < ActiveRecord::Migration
  def self.up
    create_table :branches do |t|
      t.string :name, :limit => 128, :null => false
      t.integer :repository_id, :null => false
      t.integer :commit_id, :null => false
    end
    add_index :branches, [:repository_id, :name], :unique => true,
              :null => false
  end

  def self.down
    drop_table :branches
  end
end
