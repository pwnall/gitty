require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  setup do
    @user = users(:costan)
  end
  
  test 'header_profile_image renders gravatar' do
    result = header_user_image @user
    
    assert_match(/<img .*src=".*gravatar\.com.*"/, result)
    assert_match Digest::MD5.hexdigest(@user.profile.display_email), result,
        'image tag does not contain profile e-mail hash'
  end

  test 'header_profile_image renders gravatar for user without profile' do
    user = users(:disconnected)
    result = header_user_image user
    
    assert_match(/<img .*src=".*gravatar\.com.*"/, result)
    assert_match Digest::MD5.hexdigest(user.email), result,
        'image tag does not contain user e-mail hash'
  end
end
