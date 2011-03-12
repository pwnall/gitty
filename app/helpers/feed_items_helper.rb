module FeedItemsHelper
  # The profile picture shown next to a newsfeed item.
  def feed_author_image(profile)
    image_tag profile.gravatar_url(:size => 30),
              :alt => "gravatar for #{profile.name}",
              :style => 'width: 30px; height: 30px;'
  end
end