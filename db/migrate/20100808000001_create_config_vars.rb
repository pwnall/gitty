class CreateConfigVars < ActiveRecord::Migration
  def change
    create_table :config_vars do |t|
      t.string :name, :length => 64, :null => false
      t.binary :value, :length => 1024, :null => false
    end
    add_index :config_vars, :name, :unique => true, :null => false
  end
end
