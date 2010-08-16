class RepositoriesController < ApplicationController
  # GET /gitty/repositories
  # GET /gitty/repositories.json
  def index
    @repositories = current_user.repositories
    respond_to do |format|
      format.html { redirect_to session_url }
      format.json { render :json => @repositories }
    end
  end

  # GET /costan/rails
  # GET /costan/rails.xml
  def show
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @repository }
    end
  end

  # GET /gitty/repositories/new
  # GET /gitty/repositories/new.xml
  def new
    @repository = Repository.new
    @profile = current_user.profile

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @repository }
    end
  end

  # GET /gitty/repositories/costan/rails/edit
  def edit
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
  end

  # POST /gitty/repositories
  # POST /gitty/repositories
  def create
    @repository = Repository.new(params[:repository])
    @profile = @repository.profile

    respond_to do |format|
      if @repository.save
        format.html do
          redirect_to profile_repository_url(@profile, @repository),
                      :notice => 'Repository was successfully created.'
        end
        format.xml do
          render :xml => @repository, :status => :created,
                 :location => [@profile, @repository]
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /costan/rails
  # PUT /costan/rails.xml
  def update
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first

    respond_to do |format|
      if @repository.update_attributes(params[:repository])
        format.html { redirect_to(profile_repository_url(@profile, @repository), :notice => 'Repository was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /costan/rails
  # DELETE /costan/rails.xml
  def destroy
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to(repositories_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /gitty/check_access.json?repo_path=costan/rails.git&ssh_key_id=1&commit_access=true
  def check_access
    @repository = Repository.find_by_ssh_path params[:repo_path]
    ssh_key = SshKey.where(:id => params[:ssh_key_id]).first
    @user = ssh_key && ssh_key.user
    @commit_access = params[:commit_access] && params[:commit_access] != 'false'

    message = nil
    if @repository
      if @user
        if @commit_access
          access = @repository.can_commit? @user
        else
          access = @repository.can_read? @user
        end
        unless access
          message = "You cannot #{@commit_access ? 'commit to' : 'read from'}" +
              " #{params[:repo_path]}. Ask the owner for access."
        end
      else
        message = "The SSH key is not registered with any user."
      end
    else
      message = "Repository #{params[:repo_path]} not found."
    end
    
    response = message ? { :access => false, :message => message } :
        { :access => true }
    respond_to do |format|
      format.json { render :json => response }
    end
  end
  
  # POST /gitty/change_notice.json?repo_path=costan/rails.git&ssh_key_id=1
  protect_from_forgery :except => :change_notice
  def change_notice
    @ssh_key = SshKey.find(params[:ssh_key_id])
    @repository = Repository.find_by_ssh_path params[:repo_path]

    if @repository
      @repository.integrate_changes
      success = true
      message = 'OK'
    else
      success = false
      message = "No git repository at #{params[:repo_path]}"
    end
    
    respond_to do |format|
      format.json do
        render :json => { :success => success, :message => message }
      end
    end
  end
end
