require 'test_helper'

class CommitsControllerTest < ActionController::TestCase
  setup do
    @commit = commits(:commit2)
  end

  test "should get index" do
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param
    assert_response :success
    assert_not_nil assigns(:commits)
  end

  test "should show commit" do
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :success
  end
  
  test "commit routes" do
    assert_routing({:path => '/costan/rails/commits', :method => :get},
                   {:controller => 'commits', :action => 'index',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails/commits/1234567890abcdef',
                    :method => :get},
                   {:controller => 'commits', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => '1234567890abcdef'})
  end
end
