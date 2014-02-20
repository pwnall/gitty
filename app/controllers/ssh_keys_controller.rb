class SshKeysController < ApplicationController
  # before_filter that rejects users trying to access other people's keys
  def user_owns_ssh_key
    @ssh_key = SshKey.find(params[:id])
    bounce_user unless current_user && current_user.id == @ssh_key.user_id
  end
  private :user_owns_ssh_key
  before_filter :user_owns_ssh_key, except: [:index, :new, :create]

  # GET /ssh_keys
  # GET /ssh_keys.xml
  def index
    redirect_to session_url
  end

  # GET /ssh_keys/1
  # GET /ssh_keys/1.xml
  def show
    @ssh_key = SshKey.find(params[:id])
    unless @ssh_key.user_id == current_user.id
      bounce_user
      return
    end

    respond_to do |format|
      format.html { redirect_to session_url }
      format.txt  { render text: @ssh_key.key_line }
    end
  end

  # GET /ssh_keys/new
  # GET /ssh_keys/new.xml
  def new
    @ssh_key = SshKey.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @ssh_key }
    end
  end

  # GET /ssh_keys/1/edit
  def edit
    @ssh_key = SshKey.find(params[:id])
  end

  # POST /ssh_keys
  # POST /ssh_keys.xml
  def create
    @ssh_key = SshKey.new ssh_key_params
    @ssh_key.user = current_user

    respond_to do |format|
      if @ssh_key.save
        format.html do
          redirect_to @ssh_key, notice: 'Ssh key was successfully created.'
        end
        format.xml do
          render xml: @ssh_key, status: :created, location: @ssh_key
        end
      else
        format.html do
          render action: "new"
        end
        format.xml do
          render xml: @ssh_key.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /ssh_keys/1
  # PUT /ssh_keys/1.xml
  def update
    @ssh_key = SshKey.find(params[:id])

    respond_to do |format|
      if @ssh_key.update_attributes ssh_key_params
        format.html do
          redirect_to @ssh_key, notice: 'Ssh key was successfully updated.'
        end
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml do
          render xml: @ssh_key.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # Parameters for SSH key create / update.
  def ssh_key_params
    params.require(:ssh_key).permit :name, :key_line
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
