module RepositoryPathsHelper 
  # Renders a blob path in such a way that each segment is linked to its tree.
  def blob_path_links(ref, path)
    tree_blob_path_links ref, path, true
  end  
  
  # Renders a tree path in such a way that each segment is linked to its tree.
  def tree_path_links(ref, path)
    tree_blob_path_links ref, path, false
  end
  
  # Common code for tree_path_links and blob_path_links.
  def tree_blob_path_links(ref, path, is_blob_path)
    path_array = [
      link_to(ref.repository.name, [ref.repository.profile, ref.repository]),
      link_to(ref.respond_to?(:short_gitid) ? ref.short_gitid : ref.name,
              [ref.repository.profile, ref.repository, ref])]
    subpath = nil
    path_segments = path.split('/').reject(&:empty?)
    last_segment = path_segments.pop
    path_array += path_segments.map do |segment|
      next if segment == ''
      if subpath
        subpath += '/' + segment
      else
        subpath = segment
      end
      link_to(segment, profile_repository_tree_path(ref.repository.profile,
          ref.repository, ref, subpath))
    end
    if last_segment
      if is_blob_path
        path_array << link_to(last_segment, profile_repository_blob_path(
            ref.repository.profile, ref.repository, ref, path))
      else
        path_array << link_to(last_segment, profile_repository_tree_path(
            ref.repository.profile, ref.repository, ref, path))
      end
    else
      path_array << ''
    end
    path_array.join(' / ').html_safe
  end
end
