class CreateAclEntries < ActiveRecord::Migration
  def self.up
    create_table :acl_entries do |t|
      t.string :role
      t.references :subject, :polymorphic => true
      t.references :principle, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :acl_entries
  end
end
