class CreateConfigFlags < ActiveRecord::Migration
  def self.up
    create_table :config_flags do |t|
      t.string :name, :length => 64, :null => false
      t.binary :value, :length => 1024, :null => false
    end
    add_index :config_flags, :name, :unique => true, :null => false
  end

  def self.down
    drop_table :config_flags
  end
end
