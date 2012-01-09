require 'test_helper'

class SessionMailerTest < ActionMailer::TestCase
  setup do
    @email = credentials(:jane_email).email
    @reset_token = credentials(:jane_password_token)
    @host = 'test.host'
  end

  test 'password_reset email' do
    email = SessionMailer.reset_password_email(@email, @reset_token, @host).
                          deliver
    assert !ActionMailer::Base.deliveries.empty?
    
    assert_equal 'test.host password reset', email.subject
    assert_equal ['admin@test.host'], email.from
    assert_equal '"test.host staff" <admin@test.host>', email['from'].to_s
    assert_equal [@email], email.to
    assert_match @reset_token.code, email.encoded
    assert_match @host, email.encoded
  end  
end
