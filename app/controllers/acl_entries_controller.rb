class AclEntriesController < ApplicationController
  # GET /acl_entries
  # GET /acl_entries.xml
  def index
    @acl_entries = AclEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @acl_entries }
    end
  end

  # GET /acl_entries/1
  # GET /acl_entries/1.xml
  def show
    @acl_entry = AclEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @acl_entry }
    end
  end

  # GET /acl_entries/new
  # GET /acl_entries/new.xml
  def new
    @acl_entry = AclEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @acl_entry }
    end
  end

  # GET /acl_entries/1/edit
  def edit
    @acl_entry = AclEntry.find(params[:id])
  end

  # POST /acl_entries
  # POST /acl_entries.xml
  def create
    @acl_entry = AclEntry.new(params[:acl_entry])

    respond_to do |format|
      if @acl_entry.save
        format.html { redirect_to(@acl_entry, :notice => 'Acl entry was successfully created.') }
        format.xml  { render :xml => @acl_entry, :status => :created, :location => @acl_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @acl_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /acl_entries/1
  # PUT /acl_entries/1.xml
  def update
    @acl_entry = AclEntry.find(params[:id])

    respond_to do |format|
      if @acl_entry.update_attributes(params[:acl_entry])
        format.html { redirect_to(@acl_entry, :notice => 'Acl entry was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @acl_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /acl_entries/1
  # DELETE /acl_entries/1.xml
  def destroy
    @acl_entry = AclEntry.find(params[:id])
    @acl_entry.destroy

    respond_to do |format|
      format.html { redirect_to(acl_entries_url) }
      format.xml  { head :ok }
    end
  end
end
