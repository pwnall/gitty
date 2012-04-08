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
    Set.new  %w(new_repository new_branch new_tag open_issue del_repository 
        del_branch del_tag close_issue move_branch move_tag reopen_issue 
        subscribe unsubscribe)
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
  
  # The repository pointed by the feed commit.
  def target_repository
    return @target_repository if instance_variable_defined?(:@target_repository)
    @target_repository = target_repository!
  end
  
  # The repository pointed by the feed commit.
  #
  # This method is uncached.
  def target_repository!
    if target
      # Works for Repositories, Commits, Branches and Tags.
      return target if target.kind_of? Repository
      return target.repository if target.respond_to? :repository
    end
    
    # Missing target, but the repository is still there.
    if repository_id = data[:repository_id]
      if repository = Repository.find_by_id(repository_id)
        return repository
      end
    end
    
    nil
  end
end
