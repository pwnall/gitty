class CommitsController < ApplicationController
  # GET /commits
  # GET /commits.xml
  def index
    @commits = Commit.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @commits }
    end
  end

  # GET /commits/1
  # GET /commits/1.xml
  def show
    @commit = Commit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @commit }
    end
  end
end
