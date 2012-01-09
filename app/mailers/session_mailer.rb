class SessionMailer < ActionMailer::Base
  include Authpwn::SessionMailer

  def reset_password_subject(token, server_hostname)
    # Consider replacing the hostname with a user-friendly application name.
    "#{server_hostname} password reset"
  end
  
  # The sender e-mail address for a password reset e-mail.
  def reset_password_from(token, server_hostname)
    # You most likely need to replace the e-mail address below.
    "#{server_hostname} staff <admin@#{server_hostname}>"
  end

  # Add your extensions to the SessionMailer class here.  
end
