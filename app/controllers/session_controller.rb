# Manages logging in and out of the application.
class SessionController < ApplicationController
  authpwn_session_controller
  
  # Sets up the 'session/welcome' view. No user is logged in.
  def welcome
    # You can brag about some statistics.
    @user_count = User.count
  end
  private :welcome

  # Sets up the 'session/home' view. A user is logged in.
  def home
    # Pull information about the current user.
    @profile = current_user.profile || Profile.new
  end
  private :home
  
  # You shouldn't extend the session controller, so you can benefit from future
  # features, like Facebook / Twitter / OpenID integration. But, if you must,
  # you can do it here.
end
