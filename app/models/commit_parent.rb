# Join model between a commit and its parents.
class CommitParent < ActiveRecord::Base
  # The commit.
  belongs_to :commit
  validates :commit, :presence => true
  
  # The commit's parent.
  belongs_to :parent, :class_name => 'Commit'
  validates :parent, :presence => true
end
