class CreateRepositories < ActiveRecord::Migration
  def self.up
    create_table :repositories do |t|
      t.integer :profile_id, :null => false
      t.string :name, :limit => 64, :null => false
      t.text :description, :limit => 1.kilobyte, :null => true
      t.string :url, :limit => 256, :null => true

      t.timestamps
    end
    add_index :repositories, [:profile_id, :name], :unique => true,
                             :null => false
  end

  def self.down
    drop_table :repositories
  end
end
