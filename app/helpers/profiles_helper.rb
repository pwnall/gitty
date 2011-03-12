module ProfilesHelper
  # Decorated link to a profile.
  def link_to_profile(profile)
    link_to(profile.name, profile)
  end
  
  # Large profile image, shown on the profile's page.
  def profile_image(profile)
    image_tag profile.gravatar_url(:size => 40),
              :alt => "gravatar for #{profile.name}",
              :style => 'width: 40px; height: 40px;'
  end
end
