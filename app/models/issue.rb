# Entity that needs to be tracked (e.g. bug or feature) associated with a repo.
class Issue < ActiveRecord::Base
  # The repository that this issue refers to.
  belongs_to :repository, :inverse_of => :issues
  validates :repository, :presence => true
  
  # The profile of the user who opened this issue.
  belongs_to :author, :class_name => 'Profile', :inverse_of => :issues
  validates :author, :presence => true

  # One-line summary of the issue.
  validates :title, :length => 1..160, :presence => true
  
  # Full description of the issue, including repro steps, desired behavior, etc.
  validates :description, :length => { :maximum => 1.kilobyte },
                          :exclusion => [nil]
  
  # True for issues that still require attention.
  validates :open, :inclusion => { :in => [true, false] }
end

# :nodoc: access control
class Issue
  # TODO(christy13): Verify this is the logic desired
  def can_edit?(author_profile)
    @repository.can_edit?(author_profile) or @profile == author_profile
  end
end


# :nodoc: activity feed integration
class Issue  
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
