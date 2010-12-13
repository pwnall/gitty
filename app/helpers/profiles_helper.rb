module ProfilesHelper
  # Decorated link to a profile.
  def link_to_profile(profile)
    link_to(profile.name, profile)
  end
end
