class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.string :name, :limit => 128, :null => false
      t.integer :repository_id, :null => false
      t.integer :commit_id, :null => false
    end
    add_index :branches, [:repository_id, :name], :unique => true
  end
end
