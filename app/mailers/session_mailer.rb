class SessionMailer < ActionMailer::Base
  include Authpwn::SessionMailer

  # The subject line in a password reset e-mail.
  def reset_password_subject(token, root_url)
    "#{root_url} password reset"
  end
  
  # The sender e-mail address for a password reset e-mail.
  def reset_password_from(token, root_url)
    # You must replace the e-mail address below.
    "#{root_url} staff <costan@mit.edu>"
  end

  # Add your extensions to the SessionMailer class here.  
end
