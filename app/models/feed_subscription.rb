# Connects a profile to a feed that it is subscribed to.
class FeedSubscription < ActiveRecord::Base
  # The subscribed profile.
  belongs_to :profile, inverse_of: :feed_subscriptions
  validates :profile, presence: true
  
  # The topic whose feed is followed by the user.
  belongs_to :topic, polymorphic: true,
             inverse_of: :subscriber_feed_subscriptions
  validates :topic, presence: true
  validates :topic_type, presence: true, length: 1..16
  validates :topic_id, presence: true,
                       uniqueness: { scope: [:profile_id, :topic_type] }

  # Handles the case of an existing subscription.
  def self.add(profile, topic)
    subscription = self.for(profile, topic) 
    subscription.save! if subscription.new_record?
    subscription
  end
  
  # Handles the case of no subscription.
  def self.remove(profile, topic)
    subscription = self.for(profile, topic)
    subscription.destroy unless subscription.new_record?
    subscription
  end

  # Finds or creates a subscription connecting a profile with a topic.
  #
  # The subscription might not be saved.
  def self.for(profile, topic)
     subscription(profile, topic ) ||
         FeedSubscription.new(profile: profile, topic: topic)
  end

  # Finds the subscription connecting a profile with a topic.
  def self.subscription(profile, topic)
    profile.feed_subscriptions.where(topic_id: topic.id,
                                     topic_type: topic.class.name).first
  end
end
