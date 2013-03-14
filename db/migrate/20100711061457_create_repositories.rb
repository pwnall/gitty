class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.integer :profile_id, :null => false
      t.string :name, :limit => 64, :null => false
      t.text :description, :limit => 1.kilobyte, :null => true
      t.string :url, :limit => 256, :null => true
      t.boolean :public, :null => false, :default => false

      t.timestamps
    end
    add_index :repositories, [:profile_id, :name], :unique => true
  end
end
