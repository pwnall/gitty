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
  
  # HTML representation of a blob contents.
  def marked_up_blob(blob, blob_path)
    if ConfigVar['markdpwn'] == 'enabled'
      Markdpwn.markup(blob.data, file_name: blob_path,
                                 mime_type: blob.mime_type).html_safe
    else
      content_tag :div, html_escape(blob.data), class: 'markdpwn-off-code'
    end
  end
end
