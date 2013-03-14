class AddAdminToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :admin, :default => false
    end
  end
end
