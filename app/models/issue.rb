class Issue < ActiveRecord::Base
  belongs_to :repository, :inverse_of => :issues
  belongs_to :profile, :inverse_of => :issues
  
  # Profiles following this issue.
  has_many :subscribers, :through => :subscriber_feed_subscriptions,
                         :source => :profile

  # Relation backing "subscribers".
  #
  # NOTE: The :dependent => :destroy option removes the FeedSubscriptions
  #       connecting subscribers, not the actual subscribers
  has_many :subscriber_feed_subscriptions, :class_name => 'FeedSubscription',
           :as => :topic, :inverse_of => :topic, :dependent => :destroy
  
  # Events connected to this issue.
  has_many :feed_items, :through => :feed_item_topic
  
  # Relation backing "feed_items".
  #
  # NOTE: The :dependent => :destroy option doesn't remove the FeedItem records,
  #       it only removes the FeedItemTopic records connecting to them.
  has_many :feed_item_topic, :as => :topic, :dependent => :destroy,
                             :inverse_of => :topic

  validates :title, :length => 1..32, :presence => true
  
  # TODO: Verify this is the logic desired
  def can_edit?(author_profile)
    @repository.can_edit? author_profile or @profile == author_profile
  end
  
  # Virtual attribute, backed by profile_id.
  def profile_name
    @profile_name ||= profile && profile.name
  end
  
  # Updates feeds to reflect that this issue was created.
  def publish_creation(author_profile)
    # Duplicating the profile and issue title because the issue record
    # can be deleted.
    FeedItem.publish author_profile, 'new_issue', self, [author_profile,
        self.profile, self], { :profile_name => profile.name,
                               :repo_name => self.repository,
                               :issue_title => self.title }
  end
  
  # Updates feeds to reflect that this issue was destroyed.
  def publish_deletion(author_profile)
    FeedItem.publish author_profile, 'del_issue', self, [author_profile,
        self.profile], { :profile_name => profile.name,
                         :repo_name => self.repository,
                         :issue_title => self.title }
  end
end