class AclEntriesController < ApplicationController
  include AclEntriesHelper
  
  before_filter :set_subject_from_params
  before_filter :set_acl_entry_from_params, :only => [:update, :destroy]
  before_filter :current_user_can_edit_subject  
  
  # Sets @subject (the subject for ACL entries) based on URL params.
  def set_subject_from_params
    return if @subject
    
    profile = Profile.where(:name => params[:profile_name]).first!
    if params[:repo_name].blank?
      @subject = profile
    else
      @subject = profile &&
                 profile.repositories.where(:name => params[:repo_name]).first!
    end
    
    # TODO(costan): 404 handling
  end
  
  # Sets @acl_entry based on URL params.
  def set_acl_entry_from_params
    set_subject_from_params unless @subject
    principal_class = @subject.class.acl_principal_class
    principal = principal_class.find_by_name params[:principal_name]
    @acl_entry = AclEntry.for principal, @subject
  end
  
  # before_filter verifying the current user's access to the subject in params.  
  #
  # Assumes @subject has been set by a previous call to set_subject_from_params.
  def current_user_can_edit_subject
    set_subject_from_params unless @subject
    unless @subject.can_edit?(current_user)
      bounce_user
    end
    bounce_user if @subject.kind_of?(Profile) && @subject.user
  end
  
  # GET /acl_entries
  # GET /acl_entries.json
  def index
    @acl_entry = AclEntry.new :role => @subject.class.acl_roles.first
    @acl_entry.subject = @subject
    @acl_entry.principal_type = @subject.class.acl_principal_class.name

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @acl_entries }
    end
  end

  # POST /acl_entries
  # POST /acl_entries.json
  def create
    @acl_entry = AclEntry.new params[:acl_entry]
    @acl_entry.principal_type = @subject.class.acl_principal_class.name
    @acl_entry.subject = @subject

    respond_to do |format|
      if @acl_entry.save
        format.html do
          redirect_to acl_entries_path(@subject),
                      :notice => 'Acl entry was successfully created.'
        end
        format.json do
          render :json => @acl_entry, :status => :created,
                 :location => @acl_entry
        end
      else
        format.html { render :action => :index }
        format.json do
          render :json => @acl_entry.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # PUT /acl_entries/1
  # PUT /acl_entries/1.json
  def update
    respond_to do |format|
      if @acl_entry.update_attributes params[:acl_entry]
        Rails.logger.error [acl_entries_path(@subject), @subject].inspect
        format.html do
          redirect_to acl_entries_path(@subject),
                      :notice => 'Acl entry was successfully updated.'
        end
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json do
          render :xml => @acl_entry.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  # DELETE /acl_entries/1
  # DELETE /acl_entries/1.json
  def destroy
    @acl_entry.destroy

    respond_to do |format|
      format.html { redirect_to acl_entries_path(@acl_entry.subject) }
      format.json { head :ok }
    end
  end
end
