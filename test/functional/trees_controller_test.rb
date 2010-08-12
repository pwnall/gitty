require 'test_helper'

class TreesControllerTest < ActionController::TestCase
  setup do
    @branch = branches(:master)
    @commit = @branch.commit
  end
  
  test "should show tree with commit sha" do
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'd1/d2'
    assert_response :success
    assert_equal @commit, assigns(:tree_reference)
    assert_equal 'd1/d2', assigns(:tree_path)
    assert_equal trees(:d1_d2), assigns(:tree)
  end

  test "should show tree with branch name" do
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'd1/d2'
    assert_response :success
    assert_equal @branch, assigns(:tree_reference)
    assert_equal 'd1/d2', assigns(:tree_path)
    assert_equal trees(:d1_d2), assigns(:tree)
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
    assert_equal '/', assigns(:tree_path)
    assert_equal @commit.tree, assigns(:tree)
  end
  
  test "commit routes" do
    assert_routing({:path => '/costan/rails/tree/master/docs/README',
                    :method => :get},
                   {:controller => 'trees', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => 'master', :path => 'docs/README'})
    assert_routing({:path => '/costan/rails/tree/master', :method => :get},
                   {:controller => 'trees', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => 'master'})
  end  
end
