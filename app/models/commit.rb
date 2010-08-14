# Commit in a git repository stored on this server.
class Commit < ActiveRecord::Base
  include GitObjectModel
  
  # The repository that the commit is a part of.
  belongs_to :repository
  validates :repository, :presence => true
  
  # The tree committed by this commit.
  belongs_to :tree
  
  # The commit's SHA-1, used as a unique ID.
  validates :gitid, :length => 1..64, :presence => true,
                    :uniqueness => { :scope => :repository_id }
  
  # The author's name.
  validates :author_name, :length => 1..128, :presence => true
  # The author's email.  
  validates :author_email, :length => 1..128, :presence => true
  
  # The committer's name.
  validates :committer_name, :length => 1..128, :presence => true
  # The committer's email.  
  validates :committer_email, :length => 1..128, :presence => true
  
  # The commit message.
  validates :message, :length => 1..1.kilobyte, :presence => true
  
  # The commit's parents.
  has_many :commit_parents, :dependent => :destroy
  has_many :parents, :through => :commit_parents

  # Commit model for an on-disk commit.
  #
  # Args:
  #   git_commit:: a Grit::Commit object
  #   repository:: the Repository that this commit will belong to
  #
  # Returns an unsaved Commit model. It needs to be saved before parent links
  # are created by calling CommitParent#from_git_commit.
  def self.from_git_commit(git_commit, repository)
    tree = repository.trees.where(:gitid => git_commit.tree.id).first
    self.new :repository => repository, :gitid => git_commit.id, :tree => tree,
        :author_name => git_commit.author.name,
        :author_email => git_commit.author.email,
        :committer_name => git_commit.committer.name,
        :committer_email => git_commit.committer.email,
        :authored_at => git_commit.authored_date,
        :committed_at => git_commit.committed_date,
        :message => git_commit.message
  end
  
  # Use git SHAs instead of IDs.
  def to_param
    gitid
  end
  
  # The tree or blob obtained by walking through a path in the commit's tree.
  def walk_path(path)
    tree.walk_path(path)
  end
end
