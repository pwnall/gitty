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
end

# :nodoc: synchronization with on-disk repositories
class Branch
end
