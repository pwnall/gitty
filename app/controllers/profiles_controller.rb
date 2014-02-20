class ProfilesController < ApplicationController
  # before_filter verifying that the current user is authorized to do changes
  def current_user_can_edit_profile
    @profile = Profile.where(name: params[:profile_name]).first!
    bounce_user unless @profile.can_edit? current_user
  end
  private :current_user_can_edit_profile
  before_filter :current_user_can_edit_profile,
      except: [:new, :create, :index, :show]

  # before_filter that validates the current user's ability to list accounts
  def current_user_can_list_profiles
    bounce_user unless User.can_list_users? current_user
  end
  private :current_user_can_list_profiles
  before_filter :current_user_can_list_profiles, only: [:index]

  # GET /_/profiles
  # GET /_/profiles.xml
  def index
    @profiles = Profile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @profiles }
    end
  end

  # GET /costan
  # GET /costan.xml
  def show
    @profile = Profile.where(name: params[:profile_name]).first!

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @profile }
    end
  end

  # GET /_/profiles/new
  # GET /_/profiles/new.xml
  def new
    @profile = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @profile }
    end
  end

  # GET /_/profiles/costan/edit
  def edit
  end

  # POST /_/profiles
  # POST /_/profiles.xml
  def create
    @profile = Profile.new profile_params

    respond_to do |format|
      if @profile.save
        if current_user.profile
          AclEntry.set current_user, @profile, :edit
        else
          current_user.profile = @profile
          current_user.save!
        end
        FeedSubscription.add current_user.profile, @profile

        format.html { redirect_to session_path }
        format.xml  { render xml: @profile, status: :created, location: @profile }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /costan
  # PUT /costan.xml
  def update
    respond_to do |format|
      if @profile.update_attributes profile_params
        format.html { redirect_to(@profile, notice: 'Profile was successfully updated.') }
        format.xml  { head :ok }
      else
        @original_profile = Profile.find(@profile.id)
        format.html { render action: "edit" }
        format.xml  { render xml: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # Paramaters for profile create/update.
  def profile_params
    params.require(:profile).permit :name, :display_name, :display_email,
                                    :blog, :company, :city, :language, :about
  end

  # DELETE /costan
  # DELETE /costan.xml
  def destroy
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to(profiles_url) }
      format.xml  { head :ok }
    end
  end
end
