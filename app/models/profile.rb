# The profile of an author (user or group) on the site.
class Profile < ActiveRecord::Base
  # The repositories created by this profile.
  has_many :repositories, dependent: :destroy, inverse_of: :profile

  # This profile's ACL. All entries have Users as principals.
  has_many :user_acl_entries, class_name: "AclEntry", as: :subject,
                              dependent: :destroy, inverse_of: :subject

  # The repositories that have this profile on their ACLs.
  has_many :profile_acl_entries, class_name: "AclEntry", as: :principal,
                                 dependent: :destroy, inverse_of: :principal

  # The issues opened by the user behind this profile.
  has_many :issues, inverse_of: :author, foreign_key: 'author_id',
                    dependent: :destroy

  # The ACL entries shown in the ACL editing UI.
  def acl_entries
    user_acl_entries
  end

  # The profile's short name, used in URLs.
  validates :name, length: 1..32, format: /\A\w+\Z/, presence: true,
                   uniqueness: true

  # The profile's long name.
  validates :display_name, length: 1..128, presence: true

  # The e-mail showed on the profile and on Gravatar.
  validates :display_email, length: { in: 1..128, allow_nil: true },
      format: { with: /\A[A-Za-z0-9.+_-]+@[^@]*\.(\w+)\Z/,
                   allow_nil: true }

  # The user's website or blog.
  validates :blog, length: { in: 1..128, allow_nil: true },
      format: { with: /\A(http|https):\/\//, allow_nil: true}

  # The user's company.
  validates :company, length: { in: 1..128, allow_nil: true }

  # The user's city.
  validates :city, length: { in: 1..128, allow_nil: true }

  # The user's language.
  validates :language, length: { in: 1..64, allow_nil: true }

  # The user's about page.
  validates :about, length: { in: 1..8.kilobytes, allow_nil: true }

  # For profiles that represent users (not groups).
  has_one :user, inverse_of: :profile

  # The location of the profile's repositories on disk.
  def local_path
    self.class.local_path name
  end

  # Use the profile name instead of ID in all routes.
  def to_param
    name
  end

  # True if this is a team profile.
  def team?
    user.nil?
  end

  # Users that are members of a team profile.
  def members
    team? ? user_acl_entries.map(&:principal) : []
  end


  # The location of a profile's repositories on disk.
  #
  # Args:
  #   name:: the repository's name
  def self.local_path(name)
    File.join Dir.home(ConfigVar['git_user']), 'repos', name
  end

  # :nodoc: normalize blank e-mails to nil
  def display_email=(new_email)
    new_email = nil if new_email.blank?
    super new_email
  end

  # :nodoc: normalize blank blogs to nil, add 'http://' to blogs without it
  def blog=(new_blog)
    if new_blog.blank?
      new_blog = nil
    elsif !(new_blog =~ /:\/\//)
      new_blog = 'http://' + new_blog
    end
    super new_blog
  end

  # :nodoc: normalize blank companies to nil
  def company=(new_company)
    new_company = nil if new_company.blank?
    super new_company
  end

  # :nodoc: normalize blank cities to nil
  def city=(new_city)
    new_city = nil if new_city.blank?
    super new_city
  end

  # :nodoc: normalize blank languages to nil
  def language=(new_language)
    new_language = nil if new_language.blank?
    super new_language
  end

  # :nodoc: normalize blank about pages to nil
  def about=(new_about)
    new_about = nil if new_about.blank?
    super new_about
  end
end

# :nodoc: keep on-disk user directories synchronized
class Profile
  after_create :create_profile_directory
  before_save :save_old_profile_name
  after_update :relocate_profile_directory
  after_destroy :delete_profile_directory

  # Creates a directory for the user's repositories on disk.
  def create_profile_directory
    # TODO: background job.
    FileUtils.mkdir_p local_path
    FileUtils.chmod_R 0770, local_path
    begin
      FileUtils.chown_R ConfigVar['git_user'], nil, local_path
    rescue ArgumentError
      # Happens in unit testing, when the git user isn't created yet.
      raise unless Rails.env.test?
    rescue Errno::EPERM
      # Not root, not allowed to chown.
    end
    local_path
  end

  # Relocates a Git repository on disk.
  def self.relocate_profile_directory(old_name, new_name)
    # TODO: maybe this should be a background job.
    old_path = local_path old_name
    new_path = local_path new_name
    FileUtils.mv old_path, new_path
  end

  # Saves the profile's old name, so it can be relocated.
  def save_old_profile_name
    @_old_profile_name = name_change.first if name_change
  end

  # Relocates the profile's disk directory, after the model's name is changed.
  def relocate_profile_directory
    return unless old_name = @_old_profile_name

    return if name == old_name
    self.class.relocate_profile_directory old_name, name
  end

  # Deletes the on-disk repository.
  def delete_profile_directory
    # TODO: background job.
    FileUtils.rm_r local_path if File.exist? local_path
  end
end

# :nodoc: access control
class Profile
  def can_participate?(user)
    can_x? user, [:participate, :charge, :edit]
  end

  # True if the user can charge repositories to this profile.
  def can_charge?(user)
    # NOTE: this will be replaced to support group profiles.
    can_x? user, [:charge, :edit]
  end

  # True if the user can edit the profile.
  def can_edit?(user)
    can_x? user, [:edit]
  end

  def can_x?(user, role)
    user && user_acl_entries.exists?(principal_id: user.id,
        principal_type: user.class.name, role: role)
  end
  private :can_x?

  # All the valid ACL roles when a Profile is the subject.
  def self.acl_roles
    [
      ['Contributor', :participate],
      ['Billing', :charge],
      ['Administrator', :edit]
    ]
  end

  # Expected class of principals on ACL entries whose subjects are Profiles.
  def self.acl_principal_class
    User
  end
end

# :nodoc: to be pulled into feed plugin
class Profile
  # Topics that this profile is subscribed to.
  def topics(reload = false)
    feed_subscriptions(reload).map(&:topic)
  end

  # Relationship backing "topics".
  has_many :feed_subscriptions, inverse_of: :profile, dependent: :destroy

  # Recently created items for topics that this profile is subscribed to.
  def recent_subscribed_feed_items(limit = 100)
    items = topics.map { |topic| topic.recent_feed_items(limit) }.flatten.
                   uniq.sort_by { |item| item.created_at }
    return items.reverse if items.length <= limit
    items[-limit..-1].reverse
  end

  # Feed items produced by this profile.
  #
  # This relation exists to automatically delete a profile's feed activity when
  # the profile is removed. Use feed_items to retrieve the profile's feed.
  has_many :authored_feed_items, class_name: 'FeedItem',
      foreign_key: :author_id, dependent: :destroy, inverse_of: :author


  # Profiles following this profile.
  has_many :subscribers, through: :subscriber_feed_subscriptions,
                         source: :profile

  # Relation backing "subscribers".
  has_many :subscriber_feed_subscriptions, class_name: 'FeedSubscription',
           as: :topic, inverse_of: :topic

  # Events connected to this repository.
  has_many :feed_items, through: :feed_item_topic

  # Relation backing "feed_items".
  #
  # NOTE: The :dependent => :destroy option doesn't remove the FeedItem records,
  #       it only removes the FeedItemTopic records connecting to them.
  has_many :feed_item_topic, as: :topic, dependent: :destroy,
                             inverse_of: :topic

  # Recently created events connected with this profile.
  def recent_feed_items(limit = 100)
    feed_items.order('created_at DESC').limit(limit)
  end

  # True if the given profile is subscribed to this profile's feeds.
  def subscribed?(profile)
    subscriber_feed_subscriptions.where(profile_id: profile.id).first ?
        true : false
  end

  # Updates feeds to reflect that this profile (un)subscribed to/from a feed.
  #
  # Args:
  #   subscribe:: true indicates a subscription, false shows an unsubscription
  def publish_subscription(subject, subscribe = true)
    data = case subject
    when Profile
      { profile_name: subject.name }
    when Repository
      { profile_name: subject.profile.name, repository_name: subject.name }
    else
      raise "Unsupported subject #{subject.class.name}"
    end
    verb = subscribe ? 'subscribe' : 'unsubscribe'
    FeedItem.publish self, verb, subject, [self], data
  end
end
