class RepositoriesController < ApplicationController
  # GET /repositories
  # GET /repositories.xml
  def index
    @repositories = Repository.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @repositories }
    end
  end

  # GET /repositories/1
  # GET /repositories/1.xml
  def show
    @repository = Repository.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @repository }
    end
  end

  # GET /repositories/new
  # GET /repositories/new.xml
  def new
    @repository = Repository.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @repository }
    end
  end

  # GET /repositories/1/edit
  def edit
    @repository = Repository.find(params[:id])
  end

  # POST /repositories
  # POST /repositories.xml
  def create
    @repository = Repository.new(params[:repository])

    respond_to do |format|
      if @repository.save
        format.html { redirect_to(@repository, :notice => 'Repository was successfully created.') }
        format.xml  { render :xml => @repository, :status => :created, :location => @repository }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /repositories/1
  # PUT /repositories/1.xml
  def update
    @repository = Repository.find(params[:id])

    respond_to do |format|
      if @repository.update_attributes(params[:repository])
        format.html { redirect_to(@repository, :notice => 'Repository was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1
  # DELETE /repositories/1.xml
  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to(repositories_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /check_access.json?repo_path=awesome.git&ssh_key_id=1&commit_access=true
  def check_access
    @repository_path = params[:repo_path]
    @ssh_key = SshKey.find(params[:ssh_key_id])
    @commit_access = params[:commit_access] == 'true'
    
    respond_to do |format|
      format.json { render :json => { :access => true } }
    end
  end
  
  # POST /change_notice.json?repo_path=awesome.git&ssh_key_id=1
  protect_from_forgery :except => :change_notice
  def change_notice
    @ssh_key = SshKey.find(params[:ssh_key_id])
    @repository = Repository.from_ssh_path params[:repo_path]

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
