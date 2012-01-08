require 'test_helper'

class SessionMailerTest < ActionMailer::TestCase
  setup do
    @email = credentials(:jane_email).email
    @reset_token = credentials(:jane_password_token)
    @root_url = 'http://site.com'
    @token_url = "#{@root_url}/tokens/#{@reset_token.code}"
  end

  test 'password_reset email' do
    email = SessionMailer.reset_password_email(@email, @reset_token, @root_url,
        @token_url).deliver
    assert !ActionMailer::Base.deliveries.empty?
    
    assert_equal 'http://site.com password reset', email.subject
    assert_equal 'http://site.com staff <costan@mit.edu>', email.from
    assert_equal [@email], email.to
    assert_match @token_url, email.encoded
  end  
end
