class CreateTrees < ActiveRecord::Migration
  def change
    create_table :trees do |t|
      t.integer :repository_id, :null => false
      t.string :gitid, :limit => 64, :null => false
    end
    add_index :trees, [:repository_id, :gitid], :unique => true
  end
end
