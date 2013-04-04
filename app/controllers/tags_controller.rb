class TagsController < ApplicationController
  before_filter :current_user_can_read_repo, except: :destroy
  before_filter :current_user_can_commit_to_repo, only: :destroy

  # GET /costan/rails/tags
  # GET /costan/rails/tags.xml
  def index
    @tags = @repository.tags

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @tags }
    end
  end

  # GET /costan/rails/tag/v3.0
  # GET /costan/rails/tag/v3.0.xml
  def show
    @tag = @repository.tags.where(name: params[:tag_name]).first!

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @tag }
    end
  end

  # DELETE /costan/rails/tag/v3.0
  # DELETE /costan/rails/tag/v3.0.xml
  def destroy
    @tag = @repository.tags.where(name: params[:tag_name]).first!
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
