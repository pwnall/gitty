require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup :mock_profile_paths
  
  setup do
    set_session_current_user users(:john)
    @profile = profiles(:costan)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profile" do
    assert_difference('Profile.count') do
      post :create, :profile => @profile.attributes.merge(:name => 'newest')
    end

    assert_redirected_to session_path
  end

  test "should show profile" do
    get :show, :profile_name => @profile.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :profile_name => @profile.to_param
    assert_response :success
  end

  test "should update profile" do
    put :update, :profile_name => @profile.to_param,
                 :profile => @profile.attributes
    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should destroy profile" do
    assert_difference('Profile.count', -1) do
      delete :destroy, :profile_name => @profile.to_param
    end

    assert_redirected_to profiles_path
  end
  
  test "profile routes" do
    assert_routing({:path => '/gitty/profiles', :method => :get},
                   {:controller => 'profiles', :action => 'index'})
    assert_routing({:path => '/gitty/profiles/new', :method => :get},
                   {:controller => 'profiles', :action => 'new'})
    assert_routing({:path => '/gitty/profiles', :method => :post},
                   {:controller => 'profiles', :action => 'create'})
    assert_routing({:path => '/gitty/profiles/pwnall/edit', :method => :get},
                   {:controller => 'profiles', :action => 'edit',
                    :profile_name => 'pwnall'})

    assert_routing({:path => '/pwnall', :method => :get},
                   {:controller => 'profiles', :action => 'show',
                    :profile_name => 'pwnall'})
    assert_recognizes({:controller => 'profiles', :action => 'show',
                       :profile_name => 'pwnall'},
                      {:path => '/gitty/profiles/pwnall', :method => :get})
    assert_routing({:path => '/pwnall', :method => :put},
                   {:controller => 'profiles', :action => 'update',
                    :profile_name => 'pwnall'})
    assert_recognizes({:controller => 'profiles', :action => 'update',
                       :profile_name => 'pwnall'},
                      {:path => '/gitty/profiles/pwnall', :method => :put})
    assert_routing({:path => '/pwnall', :method => :delete},
                   {:controller => 'profiles', :action => 'destroy',
                    :profile_name => 'pwnall'})
    assert_recognizes({:controller => 'profiles', :action => 'destroy',
                       :profile_name => 'pwnall'},
                      {:path => '/gitty/profiles/pwnall', :method => :delete})
  end
end
