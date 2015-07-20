require 'test_helper'

class SessionMailerTest < ActionMailer::TestCase
  setup do
    @reset_email = credentials(:dexter_email).email
    @reset_token = credentials(:dexter_password_token)
    @verification_token = credentials(:costan_email_token)
    @verification_email = credentials(:costan_email).email
    @root_url = 'hxxp://test.host/'
  end

  test 'email verification email' do
    email = SessionMailer.email_verification_email(@verification_token,
                                                   @root_url).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal 'test.host e-mail verification', email.subject
    assert_equal ['admin@gitty.org'], email.from
    assert_equal '"test.host staff" <admin@gitty.org>', email['from'].to_s
    assert_equal [@verification_email], email.to
    assert_match @verification_token.code, email.encoded
    assert_match @root_url, email.encoded
  end

  test 'password reset email' do
    email = SessionMailer.reset_password_email(@reset_email, @reset_token,
                                               @root_url).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal 'test.host password reset', email.subject
    assert_equal ['admin@gitty.org'], email.from
    assert_equal '"test.host staff" <admin@gitty.org>', email['from'].to_s
    assert_equal [@reset_email], email.to
    assert_match @reset_token.code, email.encoded
    assert_match @root_url, email.encoded
  end
end
