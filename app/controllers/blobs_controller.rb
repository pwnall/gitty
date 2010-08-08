class BlobsController < ApplicationController
  # GET /blobs
  # GET /blobs.xml
  def index
    @blobs = Blob.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blobs }
    end
  end

  # GET /blobs/1
  # GET /blobs/1.xml
  def show
    @blob = Blob.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blob }
    end
  end
end
