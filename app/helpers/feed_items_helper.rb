module FeedItemsHelper
  # The profile picture shown next to a newsfeed item.
  def feed_author_image(profile)
    image_tag profile.gravatar_url(:size => 30),
              :alt => "gravatar for #{profile.name}",
              :style => 'width: 30px; height: 30px;'
  end
  
  # The picture shown next to a commit line in a newsfeed item.
  def feed_commit_author_image(commit_data)
    image_tag Gravtastic.gravatar_url(commit_data[:author], :rating => 'PG',
        :secure => false, :filetype => :png, :size => '20'),
        :style => 'width: 20px; height: 20px;'
  end
end
