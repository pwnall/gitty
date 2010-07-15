# Entry (file or sub-directory) in a tree in a git repository on this server.
class TreeEntry < ActiveRecord::Base  
  # The parent tree.
  belongs_to :tree
  validates :tree, :presence => true
   
  # The child tree (sub-directory) or blob (file).
  belongs_to :child, :polymorphic => true
  validates :child, :presence => true

  # The child's name.
  validates :name, :length => 1..256, :presence => true
end
