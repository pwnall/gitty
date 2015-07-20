class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name, :limit => 32, :null => false
      t.string :display_name, :limit => 128, :null => false
      t.string :display_email, :limit => 128, :null => true
      t.string :blog, :limit => 128, :null => true
      t.string :company, :limit => 128, :null => true
      t.string :city, :limit => 128, :null => true
      t.string :language, :limit => 64, :null => true
      t.text :about, :limit => 8.kilobytes, :null => true

      t.timestamps :null => false
    end
    add_index :profiles, :name, :unique => true
  end
end
