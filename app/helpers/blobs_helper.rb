module BlobsHelper
  # Relative URI for a blob.
  def blob_path(blob_ref, path)
    path = path[1..-1] if path[0, 1] == '/'
    profile_repository_blob_path(blob_ref.repository.profile,
                                 blob_ref.repository, blob_ref, path)      
  end

  # Relative URI to download a blob.
  def raw_blob_path(blob_ref, path)
    path = path[1..-1] if path[0, 1] == '/'
    raw_profile_repository_blob_path(blob_ref.repository.profile,
                                     blob_ref.repository, blob_ref, path)      
  end
end
