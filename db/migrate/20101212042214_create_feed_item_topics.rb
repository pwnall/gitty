class CreateFeedItemTopics < ActiveRecord::Migration
  def change
    create_table :feed_item_topics, :force => true do |t|
      t.integer :feed_item_id, :null => false
      t.integer :topic_id, :null => false
      t.string :topic_type, :null => false, :length => 16

      t.datetime :created_at
    end
    # Display the feed for a topic.
    add_index :feed_item_topics, [:topic_id, :topic_type, :created_at],
                                 :unique => false, :null => false
    # Enforce uniqueness constraint.
    add_index :feed_item_topics, [:topic_id, :topic_type, :feed_item_id],
                                 :unique => true, :null => false,
                                 :name => :index_feed_item_topics_on_topic_item
    # Delete a feed item.
    add_index :feed_item_topics, :feed_item_id, :unique => false, :null => false
  end
end
