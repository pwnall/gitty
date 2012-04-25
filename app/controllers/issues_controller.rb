class IssuesController < ApplicationController
  before_filter :current_user_can_read_repo,
      :only => [:index, :new, :create]
      
  def current_user_can_read_issue
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @issue = @repository.issues.where(:exid => params[:issue_exid]).first
    bounce_user unless @issue.can_read? current_user
  end
  private :current_user_can_read_issue
  before_filter :current_user_can_read_issue, 
      :only => [:show]
      
  def current_user_can_edit_issue
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @issue = @repository.issues.where(:exid => params[:issue_exid]).first
    bounce_user unless @issue.can_edit? current_user
  end
  private :current_user_can_edit_issue
  before_filter :current_user_can_edit_issue, 
      :only => [:edit, :update, :destroy]
  
  # GET /costan/rails/issues
  # GET /costan/rails/issues.xml
  def index
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @issues = @repository.issues.order('created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @issues }
    end
  end

  # GET /costan/rails/issues/1
  # GET /costan/rails/issues/1.xml
  def show
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @issue = @repository.issues.where(:exid => params[:issue_exid]).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @issue }
    end
  end

  # GET /costan/rails/issues/new
  # GET /costan/rails/issues/new.xml
  def new
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first

    @issue = Issue.new
    @issue.repository = @repository

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @issue }
    end
  end

  # GET /costan/rails/issues/1/edit
  def edit
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @issue = @repository.issues.where(:exid => params[:issue_exid]).first
    
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render xml: @issue }
    end
  end

  # POST /costan/rails/issues
  # POST /costan/rails/issues.xml
  def create
    @author = current_user.profile
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    
    @issue = Issue.new params[:issue]
    @issue.repository = @repository
    @issue.author = @author
    
    respond_to do |format|
      if @issue.save
        @issue.publish_opening
        FeedSubscription.add @author, @issue
        format.html do 
          redirect_to profile_repository_issues_path(@profile, @repository),
              notice: 'Issue was successfully created.' 
         end
        format.xml do
          render :xml => @issue, :status => :created, :location => @issue
        end
      else
        format.html { render :action => :new }
        format.xml do
          render :xml => @issue.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # PUT /costan/rails/issues/1
  # PUT /costan/rails/issues/1.xml
  def update
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @issue = @repository.issues.where(:exid => params[:issue_exid]).first
    
    respond_to do |format|
      if @issue.update_attributes(params[:issue])
        # publish issue depending on being closed or reopened
        if params[:issue].has_key? :open
          if params[:issue][:open] == true || params[:issue][:open] == "true"
            @issue.publish_reopening current_user.profile
          elsif params[:issue][:open] == false || 
                params[:issue][:open] == "false"
            @issue.publish_closure current_user.profile
          else
            raise "Unimplemented open value #{params[:issue][:open]}"
          end
        end
        format.html do 
          redirect_to profile_repository_issues_path(@profile, @repository), 
              notice: 'Issue was successfully updated.'
        end
        format.xml { head :no_content }
      else
        format.html { render action: "edit" }
        format.xml do
          render :xml => @issue.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # DELETE /costan/rails/issues/1
  # DELETE /costan/rails/issues/1.xml
  def destroy
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @issue = @repository.issues.where(:exid => params[:issue_exid]).first
    
    FeedSubscription.remove @issue.author, @issue
    FeedItem.delete(FeedItem.where(:author_id => @issue.author,
                                   :target_type => "Issue",
                                   :target_id => @issue).all)
    @issue.destroy

    respond_to do |format|
      format.html do 
        redirect_to profile_repository_issues_path(@profile, @repository) 
      end
      format.xml  { head :no_content }
    end
  end
end
