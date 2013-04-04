# Tag in a git repository hosted on this server.
class Tag < ActiveRecord::Base
  # The repository that the tag belongs to.
  belongs_to :repository, inverse_of: :tags
  validates :repository, presence: true
  
  # The tag's name.
  validates :name, length: 1..128, presence: true,
                   uniqueness: { scope: :repository_id }
  
  # The commit that the tag points to.
  belongs_to :commit
  validates :commit, presence: true
  
  # The tagger's name.
  validates :committer_name, length: 1..128, presence: true
  # The tagger's email.  
  validates :committer_email, length: 1..128, presence: true
  
  # The tag message.
  validates :message, length: 1..2.kilobytes, presence: true  

  # Creates or updates a Tag model for an on-disk tag.
  #
  # Args:
  #   git_tag:: a Grit::Tag object
  #   repository:: the Repository that the branch belongs to
  #   tag:: the Tag model for the Grit::Tag (optional; will be
  #         retrieved from the database if not supplied)
  #
  # Returns an unsaved Tag model.
  def self.from_git_tag(git_tag, repository, tag = nil)
    commit = repository.commits.where(gitid: git_tag.commit.id).first
    tag ||= repository.branches.where(name: git_tag.name).first
    tag ||= self.new repository: repository, name: git_tag.name
    tag.commit = commit
    tag.committer_name = git_tag.tagger.name
    tag.committer_email = git_tag.tagger.email
    tag.committed_at = git_tag.tag_date
    tag.message = git_tag.message
    tag
  end
  
  # Use names instead of IDs.
  def to_param
    name
  end  
end
