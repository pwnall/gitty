module UsersHelper
  # Profile image shown on the header bar.
  def header_user_image(user)
    if user.profile
      subject = user.profile
      email = subject.display_email || '@'
      alt = subject.name
    else
      subject = user
      email = subject.email
      alt = subject.email
    end

    url = Gravatar.new(email).image_url :size => 30, :secure => true,
                                        :default => :mm
    image_tag url, :alt => "gravatar for #{alt}",
                   :style => 'width: 30px; height: 30px;'
  end
end
