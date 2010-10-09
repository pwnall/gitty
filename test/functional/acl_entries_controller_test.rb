require 'test_helper'

class AclEntriesControllerTest < ActionController::TestCase
  setup do
    @repository = repositories(:dexter_ghost)
    @repo_acl_entry = acl_entries(:csail_dexter_ghost)

    @profile = profiles(:csail)
    @profile_acl_entry = acl_entries(:john_csail)
    
    @session_user = @repository.profile.user
    set_session_current_user @session_user    
  end

  test "should get index for repository" do
    get :index, :profile_name => @repository.profile.to_param,
                :repo_name => @repository.to_param

    assert_response :success
    assert_equal @repository, assigns(:subject)
  end

  test "should get index for profile" do
    set_session_current_user @profile_acl_entry.principal
    get :index, :profile_name => @profile.to_param

    assert_response :success
    assert_equal @profile, assigns(:subject)
  end

  test "should create acl_entry for repository" do
    attributes = {
      :principal_name => users(:john).profile.to_param,
      :role => 'commit'
    }
    assert_difference 'AclEntry.count' do
      post :create, :profile_name => @repository.profile.to_param,
                    :repo_name => @repository.to_param, :acl_entry => attributes
    end

    assert_redirected_to acl_entries_path(@repository)
  end

  test "should create acl_entry for profile" do
    set_session_current_user @profile_acl_entry.principal
    attributes = {
      :principal_name => users(:jane).to_param,
      :role => 'charge'
    }
    assert_difference 'AclEntry.count' do
      post :create, :profile_name => @profile.to_param, :acl_entry => attributes
    end

    assert_redirected_to acl_entries_path(@profile)
  end

  test "should update acl_entry for repository" do
    put :update, :principal_name => @repo_acl_entry.principal.to_param,
                 :profile_name => @repository.profile.to_param,
                 :repo_name => @repository.to_param,
                 :acl_entry => { :role => 'read' }
    assert_redirected_to acl_entries_path(@repository)
    assert_equal 'read', @repo_acl_entry.reload.role
  end

  test "should update acl_entry for profile" do
    set_session_current_user @profile_acl_entry.principal
    put :update, :principal_name => @profile_acl_entry.principal.to_param,
                 :profile_name => @profile.to_param,
                 :acl_entry => { :role => 'read' }
    assert_redirected_to acl_entries_path(@profile)
    assert_equal 'read', @profile_acl_entry.reload.role
  end

  test "should destroy acl_entry for repository" do
    assert_difference 'AclEntry.count', -1 do
      delete :destroy, :principal_name => @repo_acl_entry.principal.to_param,
                       :profile_name => @repository.profile.to_param,
                       :repo_name => @repository.to_param
    end

    assert_redirected_to acl_entries_path(@repository)
  end

  test "should destroy acl_entry for profile" do
    set_session_current_user @profile_acl_entry.principal
    assert_difference 'AclEntry.count', -1 do
      delete :destroy, :principal_name => @profile_acl_entry.principal.to_param,
                       :profile_name => @profile.to_param
    end

    assert_redirected_to acl_entries_path(@profile)
  end
  
  test "should deny access to non-admins for repository" do
    set_session_current_user users(:john)

    get :index, :profile_name => @repository.profile.to_param,
                :repo_name => @repository.to_param
    assert_response :forbidden
    
    attributes = {
      :principal_name => users(:john).profile.to_param,
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

  test "should deny access to non-admins for profile" do
    set_session_current_user users(:jane)

    get :index, :profile_name => @profile.to_param
    assert_response :forbidden
    

    attributes = {
      :principal_name => users(:jane).to_param,
      :role => 'charge'
    }
    assert_no_difference 'AclEntry.count' do
      post :create, :profile_name => @profile.to_param, :acl_entry => attributes
    end
    assert_response :forbidden

    put :update, :principal_name => @profile_acl_entry.principal.to_param,
                 :profile_name => @profile.to_param,
                 :acl_entry => { :role => 'read' }
    assert_response :forbidden

    assert_no_difference 'AclEntry.count' do
      delete :destroy, :principal_name => @profile_acl_entry.principal.to_param,
                       :profile_name => @profile.to_param
    end
    assert_response :forbidden
  end
  
  test "profile routes" do
    assert_routing({:path => '/_/profiles/costan/acl_entries', :method => :get},
                   {:controller => 'acl_entries', :action => 'index',
                    :profile_name => 'costan'})
    assert_routing({:path => '/_/profiles/costan/acl_entries', :method => :post},
                   {:controller => 'acl_entries', :action => 'create',
                    :profile_name => 'costan'})
    assert_routing({:path => '/_/profiles/costan/acl_entries/costan@gmail.com',
                    :method => :put},
                   {:controller => 'acl_entries', :action => 'update',
                    :profile_name => 'costan',
                    :principal_name => 'costan@gmail.com'})
    assert_routing({:path => '/_/profiles/costan/acl_entries/costan@gmail.com',
                    :method => :delete},
                   {:controller => 'acl_entries', :action => 'destroy',
                    :profile_name => 'costan',
                    :principal_name => 'costan@gmail.com'})
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
