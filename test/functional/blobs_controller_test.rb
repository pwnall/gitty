require 'test_helper'

class BlobsControllerTest < ActionController::TestCase
  setup :mock_any_repository_path

  setup do
    @branch = branches(:master)
    @commit = @branch.commit
    @blob = blobs(:d1_d2_a)
  end
  
  test "should show blob with commit sha" do
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'd1/d2/a'
    assert_response :success
    assert_equal @commit, assigns(:blob_reference)
    assert_equal 'd1/d2/a', assigns(:blob_path)
    assert_equal blobs(:d1_d2_a), assigns(:blob)
  end

  test "should show blob with branch name" do
    get :show, :commit_gid => @branch.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param,
               :path => 'd1/d2/a'
    assert_response :success
    assert_equal @branch, assigns(:blob_reference)
    assert_equal 'd1/d2/a', assigns(:blob_path)
    assert_equal blobs(:d1_d2_a), assigns(:blob)
  end
  
  test "blob routes" do
    assert_routing({:path => '/costan/rails/blob/master/docs/README',
                    :method => :get},
                   {:controller => 'blobs', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => 'master', :path => 'docs/README'})
    assert_routing({:path => '/costan/rails/raw/master/docs/README',
                    :method => :get},
                   {:controller => 'blobs', :action => 'raw',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => 'master', :path => 'docs/README'})
  end  
end
