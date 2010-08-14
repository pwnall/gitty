require 'test_helper'

class RepositoriesControllerTest < ActionController::TestCase
  setup :mock_profile_paths

  setup do
    set_session_current_user users(:john)    
    @repository = repositories(:dexter_ghost)
  end

  test "should get index" do
    get :index
    assert_redirected_to session_url
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create repository" do
    attributes = @repository.attributes.merge :name => 'rails'
    assert_difference('Repository.count') do
      post :create, :repository => attributes
    end

    assert_redirected_to profile_repository_path(assigns(:repository).profile,
                                                 assigns(:repository))
  end

  test "should show repository" do
    get :show, :repo_name => @repository.to_param,
               :profile_name => @repository.profile.to_param
    assert_response :success
  end
  
  test "should show empty repository" do
    repository = repositories(:dexter_ghost)
    get :show, :repo_name => repository.to_param,,
               :profile_name => repository.profile.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :repo_name => @repository.to_param,
               :profile_name => @repository.profile.to_param
    assert_response :success
  end

  test "should update repository" do
    put :update, :repository => @repository.attributes,
        :repo_name => @repository.to_param,         
        :profile_name => @repository.profile.to_param
        
    assert_redirected_to profile_repository_path(assigns(:repository).profile,
                                                 assigns(:repository))
  end

  test "should destroy repository" do
    assert_difference('Repository.count', -1) do
      delete :destroy, :repo_name => @repository.to_param,
                       :profile_name => @repository.profile.to_param
    end

    assert_redirected_to repositories_url
  end
  
  test "repository routes" do
    assert_routing({:path => '/_/repositories', :method => :get},
                   {:controller => 'repositories', :action => 'index'})
    assert_routing({:path => '/_/repositories/new', :method => :get},
                   {:controller => 'repositories', :action => 'new'})
    assert_routing({:path => '/_/repositories', :method => :post},
                   {:controller => 'repositories', :action => 'create'})
    assert_routing({:path => '/_/repositories/costan/rails/edit',
                    :method => :get},
                   {:controller => 'repositories', :action => 'edit',
                    :profile_name => 'costan', :repo_name => 'rails'})

    assert_routing({:path => '/costan/rails', :method => :get},
                   {:controller => 'repositories', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_recognizes({:controller => 'repositories', :action => 'show',
                       :profile_name => 'costan', :repo_name => 'rails'},
                      {:path => '/_/repositories/costan/rails',
                       :method => :get})
    assert_routing({:path => '/costan/rails', :method => :put},
                   {:controller => 'repositories', :action => 'update',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_recognizes({:controller => 'repositories', :action => 'update',
                       :profile_name => 'costan', :repo_name => 'rails'},
                      {:path => '/_/repositories/costan/rails',
                       :method => :put})
    assert_routing({:path => '/costan/rails', :method => :delete},
                   {:controller => 'repositories', :action => 'destroy',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_recognizes({:controller => 'repositories', :action => 'destroy',
                       :profile_name => 'costan', :repo_name => 'rails'},
                      {:path => '/_/repositories/costan/rails',
                       :method => :delete})
  end
end
