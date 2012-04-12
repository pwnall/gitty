require 'test_helper'

class BranchesControllerTest < ActionController::TestCase
  setup do
    @branch = branches(:master)
    @session_user = @branch.repository.profile.user
    set_session_current_user @session_user
  end

  test "should get index" do
    get :index, :repo_name => @branch.repository.to_param,
                :profile_name => @branch.repository.profile.to_param
    assert_response :success
    assert_not_nil assigns(:branches)
  end

  test "should show branch" do
    get :show, :branch_name => @branch.to_param,
               :repo_name => @branch.repository.to_param,
               :profile_name => @branch.repository.profile.to_param
    assert_response :success
  end
  
  test "should grant read access to participating user" do
    set_session_current_user users(:costan)
    AclEntry.set(users(:costan).profile, @branch.repository, :participate)

    get :index, :repo_name => @branch.repository.to_param,
                :profile_name => @branch.repository.profile.to_param
    assert_response :success
    
    get :show, :branch_name => @branch.to_param,
               :repo_name => @branch.repository.to_param,
               :profile_name => @branch.repository.profile.to_param
    assert_response :success
  end

  test "should deny access to guests" do
    set_session_current_user nil
    
    get :index, :repo_name => @branch.repository.to_param,
                :profile_name => @branch.repository.profile.to_param
    assert_response :forbidden
    
    get :show, :branch_name => @branch.to_param,
               :repo_name => @branch.repository.to_param,
               :profile_name => @branch.repository.profile.to_param
    assert_response :forbidden
  end
  
  test "branch routes" do
    assert_routing({:path => '/costan/rails/branches', :method => :get},
                   {:controller => 'branches', :action => 'index',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails/branch/master',
                    :method => :get},
                   {:controller => 'branches', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :branch_name => 'master'})
  end
end
