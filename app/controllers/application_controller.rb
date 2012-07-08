class ApplicationController < ActionController::Base
  protect_from_forgery
  authenticates_using_session
  
  # before_filter verifying the current user's access to the repo in params.  
  def current_user_can_read_repo
    _current_user_can_x_repo :can_read?
  end
  
  # before_filter verifying the current user's access to the repo in params.  
  def current_user_can_commit_to_repo
    _current_user_can_x_repo :can_commit?
  end
  
  # before_filter verifying the current user's access to the repo in params.  
  def current_user_can_edit_repo
    _current_user_can_x_repo :can_edit?
  end
  
  # Implements the current_user_can_*_repo filters.
  def _current_user_can_x_repo(message)
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    
    bounce_user unless @repository.send message, current_user
  end

  # before_filter verifying the HTTP Basic user's access to the repo in params.  
  def http_user_can_read_repo
    _http_user_can_x_repo :can_read?
  end
  
  # before_filter verifying the HTTP Basic user's access to the repo in params.  
  def http_user_can_commit_to_repo
    _http_user_can_x_repo :can_commit?
  end
  
  # Implements the http_user_can_*_repo filters.
  def _http_user_can_x_repo(message)
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    
    bounce_to_http_basic unless @repository.send message, current_user
  end
end
