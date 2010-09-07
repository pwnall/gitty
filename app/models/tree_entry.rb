# Entry (file or sub-directory) in a tree in a git repository on this server.
class TreeEntry < ActiveRecord::Base  
  # The parent tree.
  belongs_to :tree
  validates :tree, :presence => true
   
  # The child tree (sub-directory) or blob (file).
  belongs_to :child, :polymorphic => true
  validates :child, :presence => true

  # The child's name.
  validates :name, :length => 1..256, :presence => true,
                   :uniqueness => { :scope => :tree_id }

  # Tree entries for an on-disk tree (directory).
  #
  # Args:
  #   git_tree:: a Grit::Tree object
  #   repository:: the Repository that this commit will belong to
  #   tree:: the Tree model for the Grit::Tree object (optional, will be looked
  #          up if not provided)
  #
  # Returns an array of unsaved TreeEntry models.
  def self.from_git_tree(git_tree, repository, tree = nil)
    tree ||= repository.trees.where(:gitid => git_tree.id).first
    blobs, trees = repository.blobs, repository.trees
    git_tree.contents.map do |git_child|
      collection = git_child.kind_of?(Grit::Blob) ? blobs : trees
      child = collection.where(:gitid => git_child.id).first
      self.new :tree => tree, :child => child, :name => git_child.name
    end
  end
end
