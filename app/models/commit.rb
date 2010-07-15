# Commit in a git repository stored on this server.
class Commit < ActiveRecord::Base
  # The repository that the commit is a part of.
  belongs_to :repository
  
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
  validates :committer, :length => 1..128, :presence => true
  # The committer's email.  
  validates :committer_email, :length => 1..128, :presence => true
  
  # The commit's parents.
  has_many :commit_parents, :dependent => :destroy
  has_many :parents, :through => :commit_parents
end
