require 'test_helper'

class TreesControllerTest < ActionController::TestCase
  setup do
    @branch = branches(:master)
    @tag = tags(:v1)
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
               :repo_name => @branch.repository.to_param,
               :profile_name => @branch.repository.profile.to_param,
               :path => 'd1/d2'
    assert_response :success
    assert_equal @branch, assigns(:tree_reference)
    assert_equal @branch, assigns(:branch)
    assert_equal 'd1/d2', assigns(:tree_path)
    assert_equal trees(:d1_d2), assigns(:tree)
  end


  test "should show tree with tag name" do
    get :show, :commit_gid => @tag.to_param,
               :repo_name => @tag.repository.to_param,
               :profile_name => @tag.repository.profile.to_param,
               :path => 'd1/d2'
    assert_response :success
    assert_equal @tag, assigns(:tree_reference)
    assert_equal @tag, assigns(:tag)
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
