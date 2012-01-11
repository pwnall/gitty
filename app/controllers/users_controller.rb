class UsersController < ApplicationController
  # before_filter that validates the current user's ability to make changes
  def current_user_can_edit_user
    @user = User.find_by_param(params[:user_param])
    bounce_user unless @user && @user.can_edit?(current_user)
  end
  private :current_user_can_edit_user
  before_filter :current_user_can_edit_user, :only => [:edit, :update, :destroy]
  
  # before_filter that validates the current user's ability to see an account
  def current_user_can_read_user
    @user = User.find_by_param(params[:user_param])
    bounce_user unless @user && @user.can_read?(current_user)
  end
  private :current_user_can_read_user
  before_filter :current_user_can_read_user, :only => [:show]
  
  # before_filter that validates the current user's ability to list accounts  
  def current_user_can_list_users
    bounce_user unless User.can_list_users? current_user
  end
  private :current_user_can_list_users
  before_filter :current_user_can_list_users, :only => [:index]
  
  before_filter :set_profile
  def set_profile
    @profile = current_user && current_user.profile
  end
  private :set_profile
  
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.json  { render :json => @user }
      format.html # new.html.erb
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        token = Tokens::EmailVerification.random_for @user.email_credential
        SessionMailer.email_verification_email(token, request.host_with_port).
                      deliver
                      
        format.html do
          redirect_to new_session_url,
              :notice => 'Please check your e-mail to verify your account.'
        end
        format.json do
          render :json => @user, :status => :created, :location => @user
        end
      else
        format.json do
          render :json => @user.errors, :status => :unprocessable_entity
        end
        format.html { render :action => :new }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
