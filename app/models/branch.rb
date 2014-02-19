# Branch in a git repository hosted on this server.
class Branch < ActiveRecord::Base
  # The repository that the branch belongs to.
  belongs_to :repository, inverse_of: :branches
  validates :repository, presence: true

  # The branch's name.
  validates :name, length: 1..128, presence: true,
                   uniqueness: { scope: :repository_id }

  # The top commit in the branch.
  belongs_to :commit
  validates :commit, presence: true

  # Creates or updates a Branch model for an on-disk branch.
  #
  # @param [Rugged::Branch] git_branch an on-disk branch
  # @param [Rugged::Repository] repository the repository that owns the branch
  # @param [Branch] branch the database model for the on-disk branch (optional;
  #     will be retrieved from the database if not supplied)
  # @return [Branch] unsaved model for the on-disk branch
  def self.from_git_branch(git_branch, repository, branch = nil)
    commit = repository.commits.where(gitid: git_branch.target_id).first
    branch ||= repository.branches.where(name: git_branch.name).first
    branch ||= self.new repository: repository, name: git_branch.name
    branch.commit = commit
    branch
  end

  # Use names instead of IDs.
  def to_param
    name
  end
end
