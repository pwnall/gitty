class IssuesController < ApplicationController
  # GET /issues
  # GET /issues.json
  def index
    #@issues = Repository.find(params[:repo_name]).issues
    @issues = Issue.all
    Rails.logger.debug "Index issues: #{@issues.inspect}"

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
    @issue = Issue.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @issue }
    end
  end

  # GET /issues/1/edit
  def edit
    @issue = Issue.find(params[:id])
  end

  # POST /issues
  # POST /issues.json
  def create
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    # @issue = @profile.issues.build(params[:issue])
    # @issue.repository_id = @repository
    # Rails.logger.debug "Issue: #{@issue.inspect}"
    # @repository.issues << @issue
    # @issue = Issue.new(params[:issue])
    @issue = Issue.new(params[:issue])
    Rails.logger.debug "Profile: #{@profile.inspect}"
    Rails.logger.debug "Issue: #{@issue.inspect}"
    @issue.repository = @repository
    @issue.profile = @profile
    @profile.issues << @issue
    @repository.issues << @issue
    Rails.logger.debug "Issue: #{@issue.inspect}"
    # Rails.logger.debug "Profile, repo: #{@profile.inspect}, #{@repository.inspect}"

    respond_to do |format|
      if @issue.save
        @issue.publish_creation @profile
        FeedSubscription.add @profile, @issue
        
        format.html { redirect_to profile_repository_issues_path(@profile, 
            @repository),
            notice: 'Issue was successfully created.' }
        format.json { render json: @issue, status: :created, location: @issue }
      else
        format.html { render action: "new" }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /issues/1
  # PUT /issues/1.json
  def update
    @issue = Issue.find(params[:id])

    respond_to do |format|
      if @issue.update_attributes(params[:issue])
        format.html { redirect_to profile_repository_issues_path(@profile, 
            @repository), 
              notice: 'Issue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy
    @issue.publish_deletion current_user.profile

    respond_to do |format|
      format.html { redirect_to profile_repository_issues_path(@profile, 
            @repository) }
      format.json { head :no_content }
    end
  end
end
