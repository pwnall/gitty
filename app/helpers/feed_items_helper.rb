module FeedItemsHelper
  # The profile picture shown next to a newsfeed item.
  def feed_author_image(profile)
    url = Gravatar.new(profile.display_email || '@').image_url size: 30,
        secure: true, default: :mm
    image_tag url, alt: "gravatar for #{profile.name}",
                   style: 'width: 30px; height: 30px;'
  end
  
  # The picture shown next to a commit line in a newsfeed item.
  def feed_commit_author_image(commit_data)
    url = Gravatar.new(commit_data[:author]).image_url size: '20',
        secure: true, default: :mm
    image_tag url, alt: 'gravatar for commit author',
                   style: 'width: 20px; height: 20px;'
  end
end
