module UsersHelper
  # Profile image shown on the header bar.
  def header_user_image(user)
    if user.profile
      subject = user.profile
      alt = subject.name
    else
      subject = user
      alt = subject.email
    end
    
    image_tag subject.gravatar_url(:size => 30), :alt => "gravatar for #{alt}",
              :style => 'width: 30px; height: 30px;'
  end
end
