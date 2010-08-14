class TagsController < ApplicationController
  # GET /costan/rails/tags
  # GET /costan/rails/tags.xml
  def index
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @tags = @repository.tags

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /costan/rails/tag/v3.0
  # GET /costan/rails/tag/v3.0.xml
  def show
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @tag = @repository.tags.where(:name => params[:tag_name]).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # DELETE /costan/rails/tag/v3.0
  # DELETE /costan/rails/tag/v3.0.xml
  def destroy
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @tag = @repository.tags.where(:name => params[:tag_name]).first
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
