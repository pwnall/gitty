class BlobsController < ApplicationController
  # GET /costan/rails/blob/master/doc/README
  def show
    process_params
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  # GET /costan/rails/raw/master/doc/README
  def raw
    process_params
    render :file => File.basename(@blob_path), :content_type => @blob.mime_type
  end
  
  def process_params
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    commit = @repository.commits.where(:gitid => params[:commit_gid]).first
    # Fallback to a branch if there's no commit with the desired name.
    if commit
      @blob_reference = commit
    else
      branch = @repository.branches.where(:name => params[:commit_gid]).first
      @blob_reference = branch
      commit = branch.commit
    end
    @blob_path = params[:path] || '/'
    @blob = commit.walk_path @blob_path
  end
  private :process_params
end
