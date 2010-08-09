class CreateConfigVars < ActiveRecord::Migration
  def self.up
    create_table :config_vars do |t|
      t.string :name, :length => 64, :null => false
      t.binary :value, :length => 1024, :null => false
    end
    add_index :config_vars, :name, :unique => true, :null => false
  end

  def self.down
    drop_table :config_vars
  end
end
