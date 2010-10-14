class AddDescriptionToRepositories < ActiveRecord::Migration
  def self.up
    add_column :repositories, :description, :text, :limit => 1.kilobyte, :null => true
    add_column :repositories, :url, :string, :limit => 256, :null => true
    add_column :repositories, :public, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :repositories, :description
    remove_column :repositories, :public
    remove_column :repositories, :url
  end
end
