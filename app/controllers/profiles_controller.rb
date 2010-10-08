class ProfilesController < ApplicationController
  # before_filter verifying that the current user is authorized to do changes
  def current_user_can_edit_profile
    @profile = Profile.where(:name => params[:profile_name]).first
    head :forbidden unless @profile.can_edit? current_user
  end
  private :current_user_can_edit_profile
  before_filter :current_user_can_edit_profile,
      :except => [:new, :create, :index, :show]
  
  # GET /profiles
  # GET /profiles.xml
  def index
    @profiles = Profile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end

  # GET /profiles/costan
  # GET /profiles/costan.xml
  def show
    @profile = Profile.where(:name => params[:profile_name]).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/new
  # GET /profiles/new.xml
  def new
    @profile = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/costan/edit
  def edit
  end

  # POST /profiles
  # POST /profiles.xml
  def create
    @profile = Profile.new(params[:profile])

    respond_to do |format|
      if @profile.save
        if current_user.profile
          # TODO(costan): add to the list of secondary profiles
        else
          current_user.profile = @profile
          current_user.save!
        end

        format.html { redirect_to session_path }
        format.xml  { render :xml => @profile, :status => :created, :location => @profile }          
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/costan
  # PUT /profiles/costan.xml
  def update
    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to(@profile, :notice => 'Profile was successfully updated.') }
        format.xml  { head :ok }
      else
        @original_profile = Profile.find(@profile.id)        
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/costan
  # DELETE /profiles/costan.xml
  def destroy
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to(profiles_url) }
      format.xml  { head :ok }
    end
  end
end
