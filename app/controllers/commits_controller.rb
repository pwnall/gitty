class CommitsController < ApplicationController
  before_filter :current_user_can_read_repo, :except => :destroy

  # GET /costan/rails/commits
  # GET /costan/rails/commits.xml
  def index
    if params[:ref_name]
      if ref = @repository.branches.where(:name => params[:ref_name]).first
        @branch = ref
      elsif ref = @repository.tags.where(:name => params[:ref_name]).first!
        @tag = ref
      end        
    else
      @branch = ref = @repository.default_branch
    end
    
    commits_page = (params[:page] || 1).to_i
    commits_page = 1 if commits_page < 1
    parent_commits = ref.commit.walk_parents((commits_page - 1) * 20, 21)
    @commits = parent_commits[0, 20]
    
    @next_page = parent_commits[20] ? commits_page + 1 : nil
    @previous_page = (commits_page > 1) ? commits_page - 1 : nil

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @commits }
    end
  end

  # GET /costan/rails/commits/12345
  # GET /costan/rails/commits/12345.xml
  def show
    @commit = @repository.commits.where(:gitid => params[:commit_gid]).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @commit }
    end
  end
end
