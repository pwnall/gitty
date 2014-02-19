# Entry (file or sub-directory) in a tree in a git repository on this server.
class TreeEntry < ActiveRecord::Base
  # The parent tree.
  belongs_to :tree, inverse_of: :entries
  validates :tree, presence: true

  # The child tree (sub-directory) or blob (file).
  belongs_to :child, polymorphic: true
  validates :child, presence: true

  # The child's name.
  validates :name, length: 1..128, presence: true,
                   uniqueness: { scope: :tree_id }

  # Tree entries for an on-disk tree (directory).
  #
  # @param [Rugged::Tree] git_tree the on-disk tree
  # @param [Repository] repository the repository that owns the tree and its
  #     entries
  # @param [Tree] the model for the on-disk tree (optional, will be looked up
  #     if not provided)
  # @return [Array<TreeEntry>] unsaved models for the on-disk tree entries
  def self.from_git_tree(git_tree, repository, tree = nil)
    tree ||= repository.trees.where(gitid: git_tree.oid).first
    blobs, trees = repository.blobs, repository.trees
    git_tree.entries.map do |git_child|
      case git_child[:type]
      when :blob, :tree
        collection = git_child[:type] == :blob ? blobs : trees
        child = collection.where(gitid: git_child[:oid]).first
      when :commit
        child = repository.submodules.where(name: git_child[:basename],
                                            gitid: git_child[:oid]).first
      else
        raise "Git tree element #{git_child.inspect} not implemented"
      end
      self.new tree: tree, child: child, name: git_child[:name]
    end
  end
end
