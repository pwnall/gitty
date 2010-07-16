# Join model between a commit and its parents.
class CommitParent < ActiveRecord::Base
  # The commit.
  belongs_to :commit
  validates :commit, :presence => true
  
  # The commit's parent.
  belongs_to :parent, :class_name => 'Commit'
  validates :parent, :presence => true
  validates :parent_id, :uniqueness => { :scope => :commit_id }

  # Parent links for an on-disk commit.
  #
  # Args:
  #   git_commit:: a Grit::Commit object
  #   repository:: the Repository that the commit will belong to
  #   commit:: the Commit model for the Grit::Commit (optional, will be looked
  #            up in the database if it's not provided)  
  #
  # Returns an array of unsaved CommitParent models.
  def self.from_git_commit(git_commit, repository, commit = nil)
    commit ||= repository.commits.where(:gitid => git_commit.id).first
    git_commit.parents.map do |git_parent|
      parent = repository.commits.where(:gitid => git_parent.id).first
      self.new :commit => commit, :parent => parent
    end
  end
end
