class ProfilesController < ApplicationController
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
    @profile = Profile.where(:name => params[:profile_name]).first
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
          current_user.update_attributes! :profile => @profile
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
    @profile = Profile.where(:name => params[:profile_name]).first

    respond_to do |format|
      if @profile.update_attributes!(params[:profile])
        format.html { redirect_to(@profile, :notice => 'Profile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/costan
  # DELETE /profiles/costan.xml
  def destroy
    @profile = Profile.where(:name => params[:profile_name]).first
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to(profiles_url) }
      format.xml  { head :ok }
    end
  end
end
