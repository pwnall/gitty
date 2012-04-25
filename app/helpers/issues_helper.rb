module IssuesHelper
  # Large profile image, shown on the profile's page.
  def issue_author_image(issue)
    url = Gravatar.new(issue.author.display_email).image_url :size => 20,
        :secure => true, :default => :mm
    image_tag url, :alt => 'gravatar for issue author',
                   :style => 'width: 20px; height: 20px;'
  end
  
  # Returns array of closed issues that a user can read.
  def readable_closed_issues(issues, user)
    issues.select { |i| i.can_read?(user) && !i.open? } 
  end
  
  # Returns array of open issues that a user can read.
  def readable_open_issues(issues, user)
    issues.select { |i| i.can_read?(user) && i.open? }
  end
  
  # Returns a user notification counting the number of open issues.
  def issue_counter(repository, user)
    count = readable_open_issues(repository.issues, user).length
    count == 0 ? '' : "(#{count})"
  end
end
