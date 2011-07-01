class CreateFeedSubscriptions < ActiveRecord::Migration
  def change
    create_table :feed_subscriptions do |t|
      t.integer :profile_id, :null => false
      t.integer :topic_id, :null => false
      t.string :topic_type, :null => false, :limit => 16

      t.datetime :created_at
    end
    # A profile's subscriptions.
    add_index :feed_subscriptions, [:profile_id, :topic_id, :topic_type],
        :unique => true, :null => false,
        :name => :index_feed_subscriptions_on_profile_topic
    # A topic's followers.
    add_index :feed_subscriptions, [:topic_id, :topic_type, :profile_id],
        :unique => true, :null => false,
        :name => :index_feed_subscriptions_on_topic_profile
  end
end
