require 'test_helper'

class SessionMailerTest < ActionMailer::TestCase
  setup do
    @reset_token = credentials(:jane_password_token)
    @root_url = 'http://site.com'
    @token_url = "#{@root_url}/tokens/#{@reset_token.code}"
  end

  test 'password_reset email' do
    flexmock(@reset_token).should_receive('user.email').
                           and_return('jane@gmail.com')
    
    email = SessionMailer.reset_password_email(@reset_token, @root_url,
        @token_url).deliver
    assert !ActionMailer::Base.deliveries.empty?
    
    assert_equal 'http://site.com password reset', email.subject
    assert_equal 'http://site.com staff <admin@site.com>', email.from
    assert_equal ['jane@gmail.com'], email.to
    assert_match @token_url, email.encoded
  end  
end
