require 'test_helper'

class CommitsControllerTest < ActionController::TestCase
  setup do
    @commit = commits(:require)
    @branch = branches(:branch1)
    @tag = tags(:v1)
    @session_user = @branch.repository.profile.user
    set_session_current_user @session_user    
    mock_any_repository_path
  end

  test "should show commits with no ref" do
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param
    assert_response :success
    assert_equal branches(:master), assigns(:branch)
    assert_equal [commits(:hello)], assigns(:commits)
    
    assert_nil assigns(:previous_page)
    assert_nil assigns(:next_page)
  end

  test "should show commits with branch ref" do
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @branch.to_param
    assert_response :success
    assert_equal @branch, assigns(:branch)
    assert_equal [commits(:require), commits(:hello)], assigns(:commits)

    assert_nil assigns(:previous_page)
    assert_nil assigns(:next_page)
  end

  test "should show commits with tag ref" do
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @tag.to_param
    assert_response :success
    assert_equal @tag, assigns(:tag)
    assert_not_nil assigns(:commits)
  end

  test "should show commit" do
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :success
  end
  
  test "should grant read access to participating user" do
    set_session_current_user users(:costan)
    AclEntry.set(users(:costan).profile, @commit.repository, :participate)

    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param
    assert_response :success
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @branch.to_param
    assert_response :success
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @tag.to_param
    assert_response :success
    
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :success    
  end

  test "should deny access to guests" do
    set_session_current_user nil
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param
    assert_response :forbidden
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @branch.to_param
    assert_response :forbidden
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @tag.to_param
    assert_response :forbidden
    
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :forbidden
  end
  
  test "commit routes" do
    assert_routing({:path => '/costan/rails/commits', :method => :get},
                   {:controller => 'commits', :action => 'index',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails/commits/v1.0', :method => :get},
                   {:controller => 'commits', :action => 'index',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :ref_name => 'v1.0'})
    assert_routing({:path => '/costan/rails/commit/1234567890abcdef',
                    :method => :get},
                   {:controller => 'commits', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => '1234567890abcdef'})
  end
end
