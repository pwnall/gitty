module CommitsHelper
  # Points to a commits listing based on some context.
  def contextual_commits_path(repository, current_branch, current_tag,
                              current_commit)        
    profile_repository_commits_path(repository.profile, repository,
        current_branch || current_tag || repository.default_branch)
  end
end
