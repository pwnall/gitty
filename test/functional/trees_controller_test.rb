require 'test_helper'

class TreesControllerTest < ActionController::TestCase
  setup do
    @branch = branches(:master)
    @tag = tags(:v1)
    @commit = @branch.commit
    @session_user = @branch.repository.profile.user
    set_session_current_user @session_user    
  end
  
  test "should show tree with commit sha" do
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'lib/ghost'
    assert_response :success
    assert_equal @commit, assigns(:tree_reference)
    assert_equal 'lib/ghost', assigns(:tree_path)
    assert_equal trees(:lib_ghost), assigns(:tree)
  end

  test "should show tree with branch name" do
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @branch.repository.to_param,
               :profile_name => @branch.repository.profile.to_param,
               :path => 'lib/ghost'
    assert_response :success
    assert_equal @branch, assigns(:tree_reference)
    assert_equal @branch, assigns(:branch)
    assert_equal 'lib/ghost', assigns(:tree_path)
    assert_equal trees(:lib_ghost), assigns(:tree)
  end

  test "should show tree with tag name" do
    get :show, :commit_gid => @tag.to_param,
               :repo_name => @tag.repository.to_param,
               :profile_name => @tag.repository.profile.to_param,
               :path => 'lib/ghost'
    assert_response :success
    assert_equal @tag, assigns(:tree_reference)
    assert_equal @tag, assigns(:tag)
    assert_equal 'lib/ghost', assigns(:tree_path)
    assert_equal trees(:lib_ghost), assigns(:tree)
  end

  test "should show commit tree with commit sha" do
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :success
    assert_equal @commit, assigns(:tree_reference)
    assert_equal '/', assigns(:tree_path)
    assert_equal @commit.tree, assigns(:tree)
  end

  test "should show commit tree with branch name" do
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :success
    assert_equal @branch, assigns(:tree_reference)
    assert_equal @branch, assigns(:branch)
    assert_equal '/', assigns(:tree_path)
    assert_equal @branch.commit.tree, assigns(:tree)
  end

  test "should show commit tree with tag name" do
    get :show, :commit_gid => @tag.to_param,
               :repo_name => @tag.repository.to_param,
               :profile_name => @tag.repository.profile.to_param
    assert_response :success
    assert_equal @tag, assigns(:tree_reference)
    assert_equal @tag, assigns(:tag)
    assert_equal '/', assigns(:tree_path)
    assert_equal @tag.commit.tree, assigns(:tree)
  end

  test "should show tree containing all sorts of objects" do
    commit = commits(:require)
    get :show, :commit_gid => commit.to_param,
               :repo_name => commit.repository.to_param,
               :profile_name => commit.repository.profile.to_param,
               :path => 'lib'
    assert_response :success
    assert_equal commit, assigns(:tree_reference)
    assert_equal 'lib', assigns(:tree_path)
    assert_equal trees(:require_lib), assigns(:tree)
    
    # TODO(pwnall): rendering tests
  end
  
  test "should grant read access to non-owner" do
    set_session_current_user users(:costan)
    AclEntry.set(users(:costan).profile, @tag.repository, :participate)

    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'lib/ghost'
    assert_response :success
    
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @branch.repository.to_param,
               :profile_name => @branch.repository.profile.to_param,
               :path => 'lib/ghost'
    assert_response :success
    
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :success
  end

  test "should deny access to guests" do
    set_session_current_user nil
    
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'lib/ghost'
    assert_response :forbidden
    
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @branch.repository.to_param,
               :profile_name => @branch.repository.profile.to_param,
               :path => 'lib/ghost'
    assert_response :forbidden
    
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :forbidden
  end
  
  test "tree routes" do
    assert_routing({:path => '/costan/rails/tree/v1.0/docs/README',
                    :method => :get},
                   {:controller => 'trees', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => 'v1.0', :path => 'docs/README'})
    assert_routing({:path => '/costan/rails/tree/v1.0', :method => :get},
                   {:controller => 'trees', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => 'v1.0'})
  end  
end
