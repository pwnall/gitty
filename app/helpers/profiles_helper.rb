module ProfilesHelper
  # Decorated link to a profile.
  def link_to_profile(profile)
    link_to(profile.name, profile)
  end

  # Large profile image, shown on the profile's page.
  def profile_image(profile)
    url = Gravatar.new(profile.display_email || '@').image_url size: 40,
        secure: true, default: :mm
    image_tag url, alt: "gravatar for #{profile.name}",
                   style: 'width: 40px; height: 40px;'
  end

  # Name of the FontAwesome icon used next to the profile's display name.
  def profile_icon_name(profile)
    profile.team? ? 'group' : 'user'
  end

  # Label used for the profile's about field.
  def profile_about_label(profile)
    profile.team? ? 'About' : 'Bio'
  end
end
