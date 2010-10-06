class AclEntriesController < ApplicationController
  before_filter :set_subject_from_params
  
  # Sets @subject (the subject for ACL entries) based on URL params.
  def set_subject_from_params
    subject_type = params[:repo_name] ? Repository : Profile
    subject_name = params[:repo_name] || params[:profile_name]
    @subject = subject_type.find_by_name subject_name    
  end
  
  # GET /acl_entries
  # GET /acl_entries.xml
  def index
    @acl_entries = @subject.acl_entries

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
    @acl_entry.subject = @subject

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @acl_entry }
    end
  end

  # GET /acl_entries/1/edit
  def edit
    @acl_entry = AclEntry.find(params[:id])
    @acl_entry.subject = @subject
  end

  # POST /acl_entries
  # POST /acl_entries.xml
  def create
    @acl_entry = AclEntry.new(params[:acl_entry])
    @acl_entry.subject = @subject

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
    @acl_entry.subject = @subject

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
