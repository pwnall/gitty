require 'test_helper'

class AclEntriesControllerTest < ActionController::TestCase
  setup do
    @repository = repositories(:dexter_ghost)
    @repo_acl_entry = acl_entries(:csail_dexter_ghost)
    
    @session_user = @repository.profile.user
    set_session_current_user @session_user    
  end

  test "should get index" do
    get :index, :profile_name => @repository.profile.to_param,
                :repo_name => @repository.to_param

    assert_response :success
    assert_not_nil assigns(:acl_entries)
    assert_operator assigns(:acl_entries), :include?, @repo_acl_entry
  end

  test "should create acl_entry for repository" do
    attributes = {
      :principal_name => users(:john).profile.to_param,
      :principal_type => users(:john).profile.class.name,
      :role => 'commit'
    }
    assert_difference 'AclEntry.count' do
      post :create, :profile_name => @repository.profile.to_param,
                    :repo_name => @repository.to_param, :acl_entry => attributes
    end

    assert_redirected_to acl_entries_path(@repository)
  end

  test "should update acl_entry for repository" do
    put :update, :principal_name => @repo_acl_entry.principal.to_param,
                 :profile_name => @repository.profile.to_param,
                 :repo_name => @repository.to_param,
                 :acl_entry => { :role => 'read' }
    assert_redirected_to acl_entries_path(@repository)
    assert_equal 'read', @repo_acl_entry.reload.role
  end

  test "should destroy acl_entry for repository" do
    assert_difference 'AclEntry.count', -1 do
      delete :destroy, :principal_name => @repo_acl_entry.principal.to_param,
                       :profile_name => @repository.profile.to_param,
                       :repo_name => @repository.to_param
    end

    assert_redirected_to acl_entries_path(@repository)
  end
  
  test "should deny access to non-admins" do
    non_owner = User.all.find { |u| u != @session_user }    
    set_session_current_user non_owner

    get :index, :profile_name => @repository.profile.to_param,
                :repo_name => @repository.to_param
    assert_response :forbidden
    
    attributes = {
      :principal_name => users(:john).profile.to_param,
      :principal_type => users(:john).profile.class.name,
      :role => 'commit'
    }
    assert_no_difference 'AclEntry.count' do
      post :create, :profile_name => @repository.profile.to_param,
                    :repo_name => @repository.to_param, :acl_entry => attributes
    end
    assert_response :forbidden

    put :update, :principal_name => @repo_acl_entry.principal.to_param,
                 :profile_name => @repository.profile.to_param,
                 :repo_name => @repository.to_param,
                 :acl_entry => { :role => 'read' }
    assert_response :forbidden

    assert_no_difference 'AclEntry.count' do
      delete :destroy, :principal_name => @repo_acl_entry.principal.to_param,
                       :profile_name => @repository.profile.to_param,
                       :repo_name => @repository.to_param
    end
    assert_response :forbidden
  end
  
  test "repository routes" do
    assert_routing({:path => '/costan/rails/acl_entries', :method => :get},
                   {:controller => 'acl_entries', :action => 'index',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails/acl_entries', :method => :post},
                   {:controller => 'acl_entries', :action => 'create',
                    :profile_name => 'costan', :repo_name => 'rails'})                    
    assert_routing({:path => '/costan/rails/acl_entries/dexter',
                    :method => :put},
                   {:controller => 'acl_entries', :action => 'update',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :principal_name => 'dexter'})
    assert_routing({:path => '/costan/rails/acl_entries/dexter',
                    :method => :delete},
                   {:controller => 'acl_entries', :action => 'destroy',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :principal_name => 'dexter'})
  end  
end
