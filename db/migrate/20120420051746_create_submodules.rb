class CreateSubmodules < ActiveRecord::Migration
  def change
    create_table :submodules do |t|
      t.references :repository, :null => false
      t.string :name, :limit => 128, :null => false
      t.string :gitid, :null => false, :limit => 64
    end
    add_index :submodules, [:repository_id, :name, :gitid], :unique => true
  end
end
