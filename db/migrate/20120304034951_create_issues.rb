class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.integer :profile_id, :null => false
      t.integer :repository_id, :null  => false
      t.boolean :open, :default => true
      t.string :title, :length => 32
      t.text :description, :length => 1.kilobyte

      t.timestamps
    end
  end
end
