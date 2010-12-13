# An event that shows up in a feed.
#
# Example: a user pushes a new branch to a repository.
class FeedItem < ActiveRecord::Base
  # The profile whose actions caused the event.
  belongs_to :author, :class_name => 'Profile',
                      :inverse_of => :authored_feed_items
  validates :author, :presence => true
  
  # The precise object impacted by the event.
  #
  # In the new branch example, the target would be the branch. The target helps
  # with navigation, but isn't used to catalog the event.
  belongs_to :target, :polymorphic => true
  validates :target, :presence => true
  validates :target_type, :length => { :in => 1..16 }

  # The action recorded by the event.
  validates :verb, :presence => true, :length => 1..16

  # One of the objects impacted by the event.
  #
  # For the example of pushing a new branch to a repository, the topics would be
  # the branch, the repository, the repository's profile, and the user's
  # profile.
  def topics(reload = false)
    feed_item_topics(reload).map(&:topic)
  end

  # Relation backing "topics".
  has_many :feed_item_topics, :inverse_of => :feed_item

  # Valid actions.
  def self.verbs
    %w(new_repository new_branch new_commits del_repository del_branch
       follow unfollow)
  end
  validates_inclusion_of :verb, :in => verbs
                                            
  # Additional unstructured information used for displaying the event.
  serialize :data
  validates :data, :length => 0..1.kilobyte
  
  # Publishes a new item to various feeds.
  def self.publish(author, verb, target, topics, data)
    item = FeedItem.create! :author => author, :verb => verb, :target => target,
                            :data =>data
    topics.uniq.each { |topic| item.feed_item_topics.create! :topic => topic }
    item
  end
end
