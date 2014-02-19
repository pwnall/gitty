# Join model between a commit and its parents.
class CommitParent < ActiveRecord::Base
  # The commit.
  belongs_to :commit, inverse_of: :commit_parents
  validates :commit, presence: true

  # The commit's parent.
  belongs_to :parent, class_name: 'Commit'
  validates :parent, presence: true
  validates :parent_id, uniqueness: { scope: :commit_id }

  # Parent links for an on-disk commit.
  #
  # @param [Rugged::commit] git_commit the on-disk commit
  # @param [Repository] repository the repository that owns the commit and its
  #     parents
  # @param [Commit] the model for the on-disk commit (optional, will be looked
  #     up if not provided)
  # @return [Array<CommitParent>] unsaved models for the parent relationships
  def self.from_git_commit(git_commit, repository, commit = nil)
    commit ||= repository.commits.where(gitid: git_commit.oid).first
    git_commit.parents.map do |git_parent|
      parent = repository.commits.where(gitid: git_parent.oid).first
      self.new commit: commit, parent: parent
    end
  end
end
