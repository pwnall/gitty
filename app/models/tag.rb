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
  # @param [Rugged::Tag] git_tag object for the on-disk tab
  # @param [Repository] repository the repository that owns the tag
  # @param [Tag] tag the database model for the on-disk tag (optional; will be
  #     retrieved from the database if not supplied)
  # @return [Tag] unsaved model for the on-disk tag
  def self.from_git_tag(git_tag, repository, tag = nil)
    # TODO(pwnall): what if the tag is not annotated?
    annotation = git_tag.annotation

    tag ||= repository.branches.where(name: annotation.name).first
    tag ||= self.new repository: repository, name: annotation.name
    tag.commit = repository.commits.where(gitid: annotation.target_id).first
    tag.committer_name = annotation.tagger[:name]
    tag.committer_email = annotation.tagger[:email]
    tag.committed_at = annotation.tagger[:time]
    tag.message = annotation.message
    tag
  end

  # Use names instead of IDs.
  def to_param
    name
  end
end
