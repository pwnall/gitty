# Manages logging in and out of the application.
class SessionController < ApplicationController
  include Authpwn::SessionController

  # Sets up the 'session/welcome' view. No user is logged in.
  def welcome
    @stats = {
      users: User.count,
      repositories: Repository.count,
      commits: Commit.count,
      files: Blob.count
    }
  end
  private :welcome

  # Sets up the 'session/home' view. A user is logged in.
  def home
    # Pull information about the current user.
    @profile = current_user.profile ||
               Profile.new(display_email: current_user.email)
  end
  private :home

  # The notification text displayed when a session authentication fails.
  def bounce_notice_text(reason)
    case reason
    when :invalid
      'Invalid e-mail or password'
    when :expired
      'Password expired. Please click "Forget password"'
    when :blocked
      'Account blocked. Please verify your e-mail address'
    end
  end

  # A user is logged in, based on a token.
  def home_with_token(token)
    respond_to do |format|
      format.html do
        case token
        when Tokens::EmailVerification
          redirect_to session_url, notice: 'E-mail address confirmed'
        when Tokens::PasswordReset
          redirect_to change_password_session_url
        # Handle other token types here.
        end
      end
      format.json do
        # Rely on default behavior.
      end
    end
  end
  private :home_with_token

  # If true, every successful login results in a SQL query that removes expired
  # session tokens from the database, to keep its size down.
  #
  # For better performance, set this to false and periodically call
  # Tokens::SessionUid.remove_expired in background thread.
  self.auto_purge_sessions = true

  # You shouldn't extend the session controller, so you can benefit from future
  # features. But, if you must, you can do it here.
end
