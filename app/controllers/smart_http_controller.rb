class SmartHttpController < ApplicationController
  # TODO(pwnall): replace this with proper access check before shipping
  before_filter :fetch_repo
  def fetch_repo
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
  end
  private :fetch_repo

  # GET costan/rails.git/info/refs
  def info_refs
    unless params[:service]
      # Using the dumb HTTP pr
      params[:path] = 'info/refs'
      return git_file
    end


  end

  # GET costan/rails.git/....
  def git_file
    file_path = @repository.internal_file_path params[:path]
    mime_type = @repository.internal_file_mime_type params[:path]
    send_file file_path, :type => mime_type
  end

  # POST costan/rails.git/git-upload-pack
  def upload_pack
  end

  # POST costan/rails.git/git-receive-pack
  def receive_pack
  end

  # Token that must be included in some GIT mime types.
  def service_name
    raw_service = params[:service]
    return false unless raw_service && raw_service[0, 4] == 'git-'
    raw_service[4..-1]
  end
  private :service_name
end
