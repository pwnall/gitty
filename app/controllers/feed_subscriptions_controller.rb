class FeedSubscriptionsController < ApplicationController
  before_filter :set_subject_from_params
  before_filter :current_user_can_read_subject  
  
  # Sets @subject (the subject for feed subscriptions) based on URL params.
  def set_subject_from_params
    return if @subject
    
    profile = Profile.where(:name => params[:profile_name]).first!
    if params[:repo_name].blank?
      @subject = profile
    else
      @subject = profile &&
                 profile.repositories.where(:name => params[:repo_name]).first!
    end
    
    # TODO(costan): 404 handling
  end
    
  # before_filter verifying the current user's access to the subject in params.  
  def current_user_can_read_subject
    set_subject_from_params unless @subject
    case @subject
    when Profile
      true
    when Repository
      bounce_user unless @subject.can_read?(current_user)
    end
  end

  # GET /costan/subscribers
  # GET /costan/subscribers.json
  # GET /costan/rails/subscribers
  # GET /costan/rails/subscribers.json
  def index
    @profiles = @subject.subscribers
    respond_to do |format|
      format.html  # subscribers.html.erb
      format.json { render :json => @profiles }
    end
  end
  
  # POST /costan/subscribers
  # POST /costan/subscribers.json
  # POST /costan/rails/subscribers
  # POST /costan/rails/subscribers.json
  def create
    FeedSubscription.add current_user.profile, @subject
    current_user.profile.publish_subscription @subject, true
    
    respond_to do |format|
      format.html { redirect_to_subject }
      format.json { head :ok }
    end
  end
  
  # DELETE /costan/subscribers
  # DELETE /costan/subscribers.json
  # DELETE /costan/rails/subscribers
  # DELETE /costan/rails/subscribers.json
  def destroy
    FeedSubscription.remove current_user.profile, @subject
    current_user.profile.publish_subscription @subject, false

    respond_to do |format|
      format.html { redirect_to_subject }
      format.json { head :ok }
    end
  end

  # Redirects to the model in the @subject instance variable.
  def redirect_to_subject
    case @subject
    when Profile
      redirect_to profile_url(@subject)
    when Repository
      redirect_to profile_repository_url(@subject.profile, @subject)
    end    
  end
  private :redirect_to_subject
end
