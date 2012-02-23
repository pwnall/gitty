module ProfilesHelper
  # Decorated link to a profile.
  def link_to_profile(profile)
    link_to(profile.name, profile)
  end
  
  # Large profile image, shown on the profile's page.
  def profile_image(profile)
    url = Gravatar.new(profile.display_email || '@').image_url :size => 40,
        :secure => true, :default => :mm
    image_tag url, :alt => "gravatar for #{profile.name}",
                   :style => 'width: 40px; height: 40px;'
  end
  
  # Determine which label to use for :about field
  #
  # "About" is used for teams, and "Bio" is used for individuals
  def profile_about_label(profile)
    if profile.team_profile?
      label = "About"
    else
      label = "Bio"
    end
    label
  end
end
