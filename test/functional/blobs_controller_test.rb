require 'test_helper'

class BlobsControllerTest < ActionController::TestCase
  setup :mock_any_repository_path

  setup do
    @branch = branches(:master)
    @tag = tags(:v1)
    @commit = @branch.commit
    @blob = blobs(:lib_ghost_hello_rb)
    @session_user = @branch.repository.profile.user
    set_session_current_user @session_user
  end
  
  test "should show blob with commit sha" do
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'lib/ghost/hello.rb'
    assert_response :success
    assert_equal @commit, assigns(:blob_reference)
    assert_equal 'lib/ghost/hello.rb', assigns(:blob_path)
    assert_equal blobs(:lib_ghost_hello_rb), assigns(:blob)
  end

  test "should show blob with branch name" do
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @branch.repository.to_param,
               :profile_name => @branch.repository.profile.to_param,
               :path => 'lib/ghost/hello.rb'
    assert_response :success
    assert_equal @branch, assigns(:blob_reference)
    assert_equal 'lib/ghost/hello.rb', assigns(:blob_path)
    assert_equal blobs(:lib_ghost_hello_rb), assigns(:blob)
  end

  test "should show blob with tag name" do
    get :show, :commit_gid => @tag.to_param,
               :repo_name => @tag.repository.to_param,
               :profile_name => @tag.repository.profile.to_param,
               :path => 'lib/ghost/hello.rb'
    assert_response :success
    assert_equal @tag, assigns(:blob_reference)
    assert_equal 'lib/ghost/hello.rb', assigns(:blob_path)
    assert_equal blobs(:lib_ghost_hello_rb), assigns(:blob)
  end

  test "should send raw blob with commit sha" do
    get :raw, :commit_gid => @commit.to_param,
              :repo_name => @commit.repository.to_param,
              :profile_name => @commit.repository.profile.to_param,
              :path => 'lib/ghost/hello.rb'
    assert_response :success
    assert_equal @commit, assigns(:blob_reference)
    assert_equal 'lib/ghost/hello.rb', assigns(:blob_path)
    assert_equal blobs(:lib_ghost_hello_rb), assigns(:blob)

    assert_equal blobs(:lib_ghost_hello_rb).data, response.body
    assert_equal 'application/ruby', response.content_type
  end
  
  test "should grant read access to participating user" do
    set_session_current_user users(:costan)
    AclEntry.set(users(:costan).profile, @commit.repository, :participate)

    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'lib/ghost/hello.rb'
    assert_response :success
    
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'lib/ghost/hello.rb'
    assert_response :success    
  end

  test "should deny access to guests" do
    set_session_current_user nil

    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'lib/ghost/hello.rb'
    assert_response :forbidden
    
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'lib/ghost/hello.rb'
    assert_response :forbidden
  end  
  
  test "blob routes" do
    assert_routing({:path => '/costan/rails/blob/master/docs/README.md',
                    :method => :get},
                   {:controller => 'blobs', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => 'master', :path => 'docs/README.md'})
    assert_routing({:path => '/costan/rails/raw/master/docs/README.md',
                    :method => :get},
                   {:controller => 'blobs', :action => 'raw',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => 'master', :path => 'docs/README.md'})
  end  
end
