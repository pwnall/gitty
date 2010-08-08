class TreesController < ApplicationController
  # GET /trees
  # GET /trees.xml
  def index
    @trees = Tree.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trees }
    end
  end

  # GET /trees/1
  # GET /trees/1.xml
  def show
    @tree = Tree.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tree }
    end
  end
end
