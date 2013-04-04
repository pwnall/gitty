require 'test_helper'

class FeedItemsHelperTest < ActionView::TestCase
  test 'feed_author_image renders gravatar' do
    author = feed_items(:dexter_creates_ghost).author
    result = feed_author_image author
    
    assert_match(/<img .*src=".*gravatar\.com.*"/, result)
    assert_match Digest::MD5.hexdigest(author.display_email), result,
        'image tag does not contain profile e-mail hash'
  end

  test 'feed_commit_author_image renders gravatar' do
    author_email = feed_items(:dexter_creates_ghost).author.display_email
    result = feed_commit_author_image author: author_email
    
    assert_match(/<img .*src=".*gravatar\.com.*"/, result)
    assert_match Digest::MD5.hexdigest(author_email), result,
        'image tag does not contain profile e-mail hash'
  end
end
