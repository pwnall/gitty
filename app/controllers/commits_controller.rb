class CommitsController < ApplicationController
  before_filter :current_user_can_read_repo, :except => :destroy

  # GET /costan/rails/commits
  # GET /costan/rails/commits.xml
  def index
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    if params[:ref_name]
      if ref = @repository.branches.where(:name => params[:ref_name]).first
        @branch = ref
      elsif ref = @repository.tags.where(:name => params[:ref_name]).first
        @tag = ref
      end        
    else
      @branch = ref = @repository.default_branch
    end
    
    # TODO(costan): List commits backwards.
    @commits = [ref.commit]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @commits }
    end
  end

  # GET /costan/rails/commits/12345
  # GET /costan/rails/commits/12345.xml
  def show
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @commit = @repository.commits.where(:gitid => params[:commit_gid]).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @commit }
    end
  end
end
