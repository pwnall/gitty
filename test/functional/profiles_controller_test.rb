require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup :mock_profile_paths
  teardown :mock_profile_paths_undo

  setup do
    @profile = profiles(:costan)
    @session_user = profiles(:costan).user
    set_session_current_user @session_user
    admin = users(:dexter)

    User.singleton_class.instance_exec do
      alias_method :real_can_list_users?, :can_list_users?
      define_method :can_list_users? do |user|
        user == admin
      end
    end
  end

  teardown do
    User.singleton_class.instance_exec do
      remove_method :can_list_users?
      alias_method :can_list_users?, :real_can_list_users?
      remove_method :real_can_list_users?
    end
  end

  test "should get index" do
    set_session_current_user users(:dexter)
    get :index
    assert_response :success
    assert_not_nil assigns(:profiles)
  end

  test "random users should not be able to list accounts" do
    get :index
    assert_response :forbidden
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user's main profile" do
    user = users(:disconnected)
    set_session_current_user user
    assert_difference('Profile.count') do
      post :create, profile: @profile.attributes.with_indifferent_access.
          except!(:id, :created_at, :updated_at).merge(name: 'newest')
    end
    assert_equal assigns(:profile), user.reload.profile
    assert_equal [assigns(:profile)], assigns(:profile).subscribers,
                 'Current user not subscribed to itself'

    assert_redirected_to session_path
  end

  test "should create user's main profile with extra form input" do
    user = users(:disconnected)
    set_session_current_user user
    assert_difference('Profile.count') do
      post :create, profile: @profile.attributes.with_indifferent_access.
          except!(:id, :created_at, :updated_at).merge(name: 'newest'),
          utf8: "\u2713", commit: 'Create Profile'
    end
    assert_equal assigns(:profile), user.reload.profile
    assert_equal [assigns(:profile)], assigns(:profile).subscribers,
                 'Current user not subscribed to itself'

    assert_redirected_to session_path
  end

  test "should create a team profile" do
    user = users(:costan)
    set_session_current_user user
    assert_difference 'Profile.count' do
      post :create, profile: @profile.attributes.with_indifferent_access.
          except!(:id, :created_at, :updated_at).merge(name: 'newest')
    end
    profile = assigns(:profile)
    assert_not_nil profile
    assert_not_equal profile, user.reload.profile
    assert_equal [user.profile], assigns(:profile).subscribers,
                 'Current user not subscribed to team profile'

    assert_redirected_to session_path
  end

  test "should show profile" do
    get :show, profile_name: @profile.to_param
    assert_response :success

    assert_select %Q|a[href*="#{edit_profile_path(@profile)}"]|
  end

  test "should show a user profile's teams" do
    set_session_current_user nil
    get :show, profile_name: @profile.to_param
    assert_response :success
    assert_equal @profile, assigns(:profile)
    assert_select '.profiles' do
      assert_select 'li', 2
      assert_select 'li:nth-child(1)', 'csail'
      assert_select 'li:nth-child(2)', 'mit'
    end
  end

  test "should not show the edit profile link when nobody is logged in" do
    set_session_current_user nil
    get :show, profile_name: @profile.to_param
    assert_response :success
    assert_equal @profile, assigns(:profile)
    assert_select %Q|a[href*="#{edit_profile_path(@profile)}"]|, 0
  end

  test "should get edit" do
    get :edit, profile_name: @profile.to_param
    assert_response :success
  end

  test "should update profile" do
    put :update, profile_name: @profile.to_param,
        profile: @profile.attributes.with_indifferent_access.
        except!(:id, :created_at, :updated_at)
    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should rename profile" do
    old_local_path = @profile.local_path
    FileUtils.mkdir_p old_local_path

    put :update, profile_name: @profile.to_param,
        profile: @profile.attributes.with_indifferent_access.
        except!(:id, :created_at, :updated_at).merge(name: 'randomness')


    assert_equal 'randomness', @profile.reload.name

    assert_not_equal old_local_path, @profile.local_path,
                     'rename test case broken'
    assert !File.exist?(old_local_path), 'profile not renamed'
    assert File.exist?(@profile.local_path), 'profile not renamed'

    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should use old profile url on rejected rename" do
    put :update, profile_name: @profile.to_param,
        profile: @profile.attributes.with_indifferent_access.
        except!(:id, :created_at, :updated_at).merge(name: '-broken')

    assert_not_equal '-broken', @profile.reload.name
    assert_template :edit
    assert_select "form[action=#{profile_path(@profile)}]"
    assert_select 'input[id=profile_name][value="-broken"]'
  end

  test "should destroy profile" do
    assert_difference('Profile.count', -1) do
      delete :destroy, profile_name: @profile.to_param
    end

    assert_redirected_to profiles_path
  end

  test "should grant read access to non-owner" do
    non_owner = User.all.find { |u| u != @session_user }
    assert non_owner, 'non-owner finding failed'
    set_session_current_user non_owner

    get :show, profile_name: @profile.to_param
    assert_response :success

    get :edit, profile_name: @profile.to_param
    assert_response :forbidden

    put :update, profile_name: @profile.to_param,
                 profile: @profile.attributes
    assert_response :forbidden

    assert_no_difference 'Repository.count' do
      delete :destroy, profile_name: @profile.to_param
    end
    assert_response :forbidden
  end

  test "profile routes" do
    assert_routing({path: '/_/profiles', method: :get},
                   {controller: 'profiles', action: 'index'})
    assert_routing({path: '/_/profiles/new', method: :get},
                   {controller: 'profiles', action: 'new'})
    assert_routing({path: '/_/profiles', method: :post},
                   {controller: 'profiles', action: 'create'})
    assert_routing({path: '/_/profiles/costan/edit', method: :get},
                   {controller: 'profiles', action: 'edit',
                    profile_name: 'costan'})

    assert_routing({path: '/costan', method: :get},
                   {controller: 'profiles', action: 'show',
                    profile_name: 'costan'})
    assert_recognizes({controller: 'profiles', action: 'show',
                       profile_name: 'costan'},
                      {path: '/_/profiles/costan', method: :get})
    assert_routing({path: '/costan', method: :put},
                   {controller: 'profiles', action: 'update',
                    profile_name: 'costan'})
    assert_recognizes({controller: 'profiles', action: 'update',
                       profile_name: 'costan'},
                      {path: '/_/profiles/costan', method: :put})
    assert_routing({path: '/costan', method: :delete},
                   {controller: 'profiles', action: 'destroy',
                    profile_name: 'costan'})
    assert_recognizes({controller: 'profiles', action: 'destroy',
                       profile_name: 'costan'},
                      {path: '/_/profiles/costan', method: :delete})
  end
end
