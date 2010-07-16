# Branch in a git repository hosted on this server.
class Branch < ActiveRecord::Base
  # The repository that the branch belongs to.
  belongs_to :repository
  validates :repository, :presence => true
  
  # The branch's name.
  validates :name, :length => 1..128, :presence => true,
                   :uniqueness => { :scope => :repository_id }
  
  # The top commit in the branch.
  belongs_to :commit
  validates :commit, :presence => true

  # Creates or updates a Branch model for an on-disk branch.
  #
  # Args:
  #   git_branch:: a Grit::Branch object
  #   repository:: the Repository that the branch belongs to
  #   branch:: the Branch model for the Grit::Branch (optional; will be
  #            retrieved from the database if not supplied)
  #
  # Returns an unsaved Branch model.
  def self.from_git_branch(git_branch, repository, branch = nil)
    commit = repository.commits.where(:gitid => git_branch.commit.id).first
    branch ||= repository.branches.where(:name => git_branch.name).first
    branch ||= self.new :repository => repository, :name => git_branch.name
    branch.commit = commit
    branch
  end
end
