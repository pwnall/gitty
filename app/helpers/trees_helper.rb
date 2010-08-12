module TreesHelper
  # Relative URI for a tree.
  def tree_path(tree_ref, path = nil)
    if path.nil?      
      profile_repository_commit_tree_path(tree_ref.repository.profile,
                                          tree_ref.repository, tree_ref)
    else
      path = path[1..-1] if path[0, 1] == '/'
      profile_repository_tree_path(tree_ref.repository.profile,
                                   tree_ref.repository, tree_ref, path)      
    end
  end
end
