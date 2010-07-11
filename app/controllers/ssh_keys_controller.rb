class SshKeysController < ApplicationController
  # GET /ssh_keys
  # GET /ssh_keys.xml
  def index
    @ssh_keys = SshKey.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ssh_keys }
    end
  end

  # GET /ssh_keys/1
  # GET /ssh_keys/1.xml
  def show
    @ssh_key = SshKey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ssh_key }
    end
  end

  # GET /ssh_keys/new
  # GET /ssh_keys/new.xml
  def new
    @ssh_key = SshKey.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ssh_key }
    end
  end

  # GET /ssh_keys/1/edit
  def edit
    @ssh_key = SshKey.find(params[:id])
  end

  # POST /ssh_keys
  # POST /ssh_keys.xml
  def create
    @ssh_key = SshKey.new(params[:ssh_key])

    respond_to do |format|
      if @ssh_key.save
        format.html { redirect_to(@ssh_key, :notice => 'Ssh key was successfully created.') }
        format.xml  { render :xml => @ssh_key, :status => :created, :location => @ssh_key }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ssh_key.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ssh_keys/1
  # PUT /ssh_keys/1.xml
  def update
    @ssh_key = SshKey.find(params[:id])

    respond_to do |format|
      if @ssh_key.update_attributes(params[:ssh_key])
        format.html { redirect_to(@ssh_key, :notice => 'Ssh key was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ssh_key.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ssh_keys/1
  # DELETE /ssh_keys/1.xml
  def destroy
    @ssh_key = SshKey.find(params[:id])
    @ssh_key.destroy

    respond_to do |format|
      format.html { redirect_to(ssh_keys_url) }
      format.xml  { head :ok }
    end
  end
end
