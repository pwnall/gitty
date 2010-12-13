module RepositoriesHelper
  # Decorated link to a repository.
  def link_to_repository(repository)
    link_to(repository.profile.name, repository.profile) + "/" +
        link_to("#{repository.name}",
                profile_repository_path(repository.profile, repository))
  end
end
