# Branch in a git repository hosted on this server.
class Branch < ActiveRecord::Base
  # The repository that the branch belongs to.
  belongs_to :repository
  validates :repository, :presence => true
  
  # The branch's name.
  validates :name, :length => 1..128, :presence => true
  
  # The top commit in the branch.
  belongs_to :commit
  validates :commit, :presence => true

  # Creates or updates a Branch model for an on-disk branch.
  #
  # Args:
  #   git_branch:: a Grit::Branch object
  #   repository:: the Repository that the branch belongs to
  #
  # Returns an unsaved Branch model.
  def from_git(git_branch, repository)
    commit = repository.commits.where(:gitid => git_branch.commit.id).first
    branch = repository.branches.where(:name => git_branch.name).first
    branch ||= self.new :name => git_branch.name
    branch.commit = commit
    branch
  end
end
