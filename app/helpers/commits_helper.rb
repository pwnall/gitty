module CommitsHelper
  # Points to a commits listing based on some context.
  def contextual_commits_path(repository, current_branch, current_tag,
                              current_commit)        
    profile_repository_commits_path(repository.profile, repository,
        current_branch || current_tag || repository.default_branch)
  end
  
  # Large profile image, shown on the profile's page.
  def commit_author_image(commit)
    url = Gravatar.new(commit.author_email).image_url size: 20,
        secure: true, default: :mm
    image_tag url, alt: 'gravatar for commit author',
                   style: 'width: 20px; height: 20px;'
  end
end
