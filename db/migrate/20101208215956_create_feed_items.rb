class CreateFeedItems < ActiveRecord::Migration
  def self.up
    create_table :feed_items do |t|
      t.integer :author_id, :null => false
      t.string :verb, :null => false, :length => 16
      t.integer :target_id, :null => false
      t.string :target_type, :null => false, :length => 16
      t.text :data, :length => 1.kilobyte

      t.datetime :created_at
    end
    # Delete all the feed items of a profile.
    add_index :feed_items, :author_id, :unique => false, :null => false
  end

  def self.down
    drop_table :feed_items
  end
end
