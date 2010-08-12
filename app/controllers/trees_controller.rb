class TreesController < ApplicationController
  # GET /costan/rails/tree/master/test/unit/helpers
  def show
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    commit = @repository.commits.where(:gitid => params[:commit_gid]).first
    # Fallback to a branch if there's no commit with the desired name.
    if commit
      @tree_reference = commit
    else
      branch = @repository.branches.where(:name => params[:commit_gid]).first
      @tree_reference = branch
      commit = branch.commit
    end
    @tree_path = params[:path] || '/'
    @tree = commit.walk_path @tree_path
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tree }
    end
  end
end
