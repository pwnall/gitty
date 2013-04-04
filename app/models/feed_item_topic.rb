# Connects a feed item with one of the topics that it belongs to.
class FeedItemTopic < ActiveRecord::Base
  # The topic connected to the event.
  belongs_to :topic, polymorphic: true
  validates :topic, presence: true
  validates :topic_type, length: { in: 1..16, allow_nil: true }
  validates :topic_id, numericality: { integer_only: true, allow_nil: true }

  # The event connected to the topic.
  belongs_to :feed_item, inverse_of: :feed_item_topics
  validates :feed_item, presence: true
  validates :feed_item_id, uniqueness: { scope: [:topic_id, :topic_type] }
end
