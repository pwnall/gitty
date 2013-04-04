# Entity that needs to be tracked (e.g. bug or feature) associated with a repo.
class Issue < ActiveRecord::Base
  # The repository that this issue refers to.
  belongs_to :repository, inverse_of: :issues
  validates :repository, presence: true

  # The profile of the user who opened this issue.
  belongs_to :author, class_name: 'Profile', inverse_of: :issues
  validates :author, presence: true

  # One-line summary of the issue.
  validates :title, length: 1..160, presence: true

  # Full description of the issue, including repro steps, desired behavior, etc.
  validates :description, length: { maximum: 1.kilobyte }, exclusion: [nil]

  # True for issues that still require attention.
  validates :open, inclusion: { in: [true, false] }

  # True for issues that have sensitive information and so will only be seen by
  # the developers and the author.
  validates :sensitive, inclusion: { in: [true, false] }

  # Externally-visible issue ID.
  #
  # This is decoupled from "id" column to avoid leaking information about
  # the application's usage.
  validates :number, presence: true, numericality: { greater_than: 0 },
      uniqueness: { scope: :repository_id }

  # Automatically set the number
  before_validation :set_default_number, on: :create

  # Use external IDs for routes instead of IDs.
  def to_param
    number.to_s
  end

  # The next valid number that can be assigned to an issue.
  def self.next_number(repository)
    if repository && !repository.issues.empty?
      return repository.issues.order('number DESC').first.number + 1
    end
    1  # Issue numbering is 1-based.
  end

  # If the issue doesn't have a number, gives it the next available number.
  def set_default_number
    self.number ||= self.class.next_number repository
  end
end

# :nodoc: access control
class Issue
  def can_edit?(user)
    repository.can_edit?(user) || (user && user.profile == author)
  end

  def can_read?(user)
    if sensitive?
      repository.can_edit?(user) || (user && user.profile == author)
    else
      repository.can_read?(user)
    end
  end
end

# :nodoc: activity feed integration
class Issue
  # Profiles following this issue.
  has_many :subscribers, through: :subscriber_feed_subscriptions,
                         source: :profile

  # Relation backing "subscribers".
  #
  # NOTE: The :dependent => :destroy option removes the FeedSubscriptions
  #       connecting subscribers, not the actual subscribers
  has_many :subscriber_feed_subscriptions, class_name: 'FeedSubscription',
           as: :topic, inverse_of: :topic, dependent: :destroy

  # Events connected to this issue.
  has_many :feed_items, through: :feed_item_topic

  # Relation backing "feed_items".
  #
  # NOTE: The :dependent => :destroy option doesn't remove the FeedItem records,
  #       it only removes the FeedItemTopic records connecting to them.
  has_many :feed_item_topic, as: :topic, dependent: :destroy,
                             inverse_of: :topic


  # Recently created events connected with this issue.
  def recent_feed_items(limit = 100)
    feed_items.order('created_at DESC').limit(limit)
  end

  # Updates feeds to reflect that this issue was created.
  # TODO(pwnall): Filter issue feed items by reading access
  def publish_opening
    # Duplicating the profile and issue title because the issue record
    # can be deleted.
    return if sensitive?
    FeedItem.publish author, 'open_issue', self,
        [author, repository, repository.profile, self],
        profile_name: repository.profile.name, repo_name: repository.name,
        author_name: author.name, issue_title: title
  end

  # Updates feeds to reflect that this issue was closed.
  # TODO(pwnall): Filter issue feed items by reading access
  def publish_closure(author_profile)
    return if sensitive?
    FeedItem.publish author_profile, 'close_issue', self,
        [author_profile, repository, repository.profile, self],
        profile_name: repository.profile.name, repo_name: repository.name,
        author_name: author.name, issue_title: title
  end

  # Updates feeds to reflect that this issue was reopened.
  # TODO(pwnall): Filter issue feed items by reading access
  def publish_reopening(author_profile)
    # Duplicating the profile and issue title because the issue record
    # can be deleted.
    return if sensitive?
    FeedItem.publish author_profile, 'reopen_issue', self,
        [author_profile, repository, repository.profile, self],
        profile_name: repository.profile.name, repo_name: repository.name,
        author_name: author.name, issue_title: title
  end
end
