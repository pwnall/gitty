class IssuesController < ApplicationController
  before_filter :current_user_can_read_repo, 
      :except => [:edit, :destroy, :update]
      
  def current_user_can_edit_issue
    @issue = Issue.find(params[:id])
    unless @issue.can_edit? current_user || @issue.author == current_user
      bounce_user
    end
  end
  private :current_user_can_edit_issue
  before_filter :current_user_can_edit_issue, 
      :only => [:edit, :destroy, :update]
  
  # GET /issues
  # GET /issues.json
  def index
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @issues = @repository.issues.order('created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @issues }
    end
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    @issue = Issue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @issue }
    end
  end

  # GET /issues/new
  # GET /issues/new.json
  def new
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first

    @issue = Issue.new
    @issue.repository = @repository

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @issue }
    end
  end

  # GET /issues/1/edit
  def edit
    @issue = Issue.find(params[:id])
    @repository = @issue.repository
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @issue }
    end
  end

  # POST /issues
  # POST /issues.json
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
        format.json { render json: @issue, status: :created, location: @issue }
      else
        format.html { render action: "new" }
        format.json do 
          render json: @issue.errors, status: :unprocessable_entity 
        end
      end
    end
  end

  # PUT /issues/1
  # PUT /issues/1.json
  def update
    @issue = Issue.find(params[:id])
    
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
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json do 
          render json: @issue.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @issue = Issue.find(params[:id])
    FeedSubscription.remove @issue.author, @issue
    FeedItem.delete(FeedItem.where(:author_id => @issue.author,
                                   :target_type => "Issue",
                                   :target_id => @issue).all)
    @issue.destroy

    respond_to do |format|
      format.html do 
        redirect_to profile_repository_issues_path(@profile, @repository) 
      end
      format.json { head :no_content }
    end
  end
end
