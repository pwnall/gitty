require 'test_helper'

class ProfilesHelperTest < ActionView::TestCase
  setup do
    @profile = profiles(:dexter)
  end

  test 'link_to_profile' do
    golden = '<a href="/dexter">dexter</a>'
    assert_equal golden, link_to_profile(@profile)
  end
  
  test 'profile_image renders gravatar' do
    result = profile_image @profile
    
    assert_match(/<img .*src=".*gravatar\.com.*"/, result)
    assert_match Digest::MD5.hexdigest(@profile.display_email), result,
        'image tag does not contain profile e-mail hash'
  end
end
