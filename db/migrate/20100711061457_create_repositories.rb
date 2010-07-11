class CreateRepositories < ActiveRecord::Migration
  def self.up
    create_table :repositories do |t|
      t.string :name, :limit => 64, :null => false

      t.timestamps
    end
    add_index :repositories, :name, :unique => true, :null => false
  end

  def self.down
    drop_table :repositories
  end
end
