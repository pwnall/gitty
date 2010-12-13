module RepositoriesHelper
  include ProfilesHelper
  
  # Decorated link to a repository.
  def link_to_repository(repository)
    link_to_profile(repository.profile) + '/' +
        link_to(repository.name,
                profile_repository_path(repository.profile, repository))
  end
end
