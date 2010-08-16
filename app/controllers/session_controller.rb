# Manages logging in and out of the application.
class SessionController < ApplicationController
  authpwn_session_controller
  
  # Sets up the 'session/welcome' view. No user is logged in.
  def welcome
    @stats = {
      :users => User.count,
      :repositories => Repository.count,
      :commits => Commit.count,
      :files => Blob.count
    }
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
