# Tree (directory) in a git repository hosted on this server.
class Tree < ActiveRecord::Base
  # The repository that this tree is a part of.
  belongs_to :repository
  validates :repository, :presence => true
  
  # The git object id (sha of the object's data).
  validates :gitid, :length => 1..64, :presence => true,
                    :uniqueness => { :scope => :repository_id }  

  # The tree's contents.
  has_many :entries
end
