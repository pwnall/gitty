require 'test_helper'

class RepositoriesControllerTest < ActionController::TestCase
  setup :mock_profile_paths

  setup do
    @repository = repositories(:dexter_ghost)
    @author = users(:jane)
    @author_key = @author.ssh_keys.first
    @reader = users(:john)
    @reader_key = @reader.ssh_keys.first

    set_session_current_user @author
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
    attributes = @repository.attributes.merge :name => 'rails',
        :profile_name => @repository.profile.name
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
  
  test "should show git directions to author for empty repository" do
    repository = repositories(:costan_ghost)
    set_session_current_user users(:john)
    get :show, :repo_name => repository.to_param,
               :profile_name => repository.profile.to_param
    assert_response :success
    assert_select '.bootstrap_steps'
  end
  
  test "should show oops page to non-committer for empty repository" do
    repository = repositories(:costan_ghost)
    set_session_current_user users(:jane)

    get :show, :repo_name => repository.to_param,
               :profile_name => repository.profile.to_param
    assert_response :success
    assert_select '.empty_repository'
  end

  test "should get edit" do
    get :edit, :repo_name => @repository.to_param,
               :profile_name => @repository.profile.to_param
    assert_response :success
  end

  test "should update repository" do
    attributes =
        @repository.attributes.merge :profile_name => @repository.profile.name

    put :update, :repository => attributes,
        :repo_name => @repository.to_param,
        :profile_name => @repository.profile.to_param
        
    assert_redirected_to profile_repository_path(assigns(:repository).profile,
                                                 assigns(:repository))
  end
  
  test "should rename repository" do
    old_local_path = @repository.local_path
    FileUtils.mkdir_p old_local_path
    attributes = @repository.attributes.merge(
        :profile_name => @repository.profile.name, :name => 'randomness')

    put :update, :repository => attributes,
        :repo_name => @repository.to_param,
        :profile_name => @repository.profile.to_param
    
    assert_equal 'randomness', @repository.reload.name
    
    assert_not_equal old_local_path, @repository.local_path,
                     'rename test case broken'
    assert !File.exist?(old_local_path), 'repository not renamed'
    assert File.exist?(@repository.local_path), 'repository not renamed'
    
    assert_redirected_to profile_repository_path(assigns(:repository).profile,
                                                 assigns(:repository))        
  end
  
  test "should use old repository url on rejected rename" do
    attributes = @repository.attributes.merge(
        :profile_name => @repository.profile.name, :name => '-broken')

    put :update, :repository => attributes,
        :repo_name => @repository.to_param,
        :profile_name => @repository.profile.to_param
    
    assert_not_equal '-broken', @repository.reload.name
    repo_path = profile_repository_path(@repository.profile, @repository)
    assert_template :edit
    assert_select "form[action=#{repo_path}]"
    assert_select 'input[id=repository_name][value="-broken"]'
  end

  test "should destroy repository" do
    assert_difference 'Repository.count', -1 do
      delete :destroy, :repo_name => @repository.to_param,
                       :profile_name => @repository.profile.to_param
    end

    assert_redirected_to repositories_url
  end
  
  test "should grant read access to non-owner" do
    non_owner = User.all.find { |u| u != @author }
    assert non_owner, 'non-owner finding failed'
    set_session_current_user non_owner
    
    get :show, :repo_name => @repository.to_param,
               :profile_name => @repository.profile.to_param
    assert_response :success
    
    get :edit, :repo_name => @repository.to_param,
               :profile_name => @repository.profile.to_param
    assert_response :forbidden
    
    put :update, :repository => @repository.attributes,
        :repo_name => @repository.to_param,
        :profile_name => @repository.profile.to_param
    assert_response :forbidden
    
    assert_no_difference 'Repository.count' do
      delete :destroy, :repo_name => @repository.to_param,
                       :profile_name => @repository.profile.to_param
    end
    assert_response :forbidden
  end
  
  test "should reject unauthorized charging via create" do
    attributes = @repository.attributes.merge :name => 'rails',
        :profile_name => 'costan'
    assert_no_difference 'Repository.count' do
      post :create, :repository => attributes
    end
    assert_response :forbidden
  end
  
  test "should reject unauthorized charging via update" do
    attributes = @repository.attributes.merge :profile_name => 'costan'
    put :update, :repository => attributes, :repo_name => @repository.to_param,
        :profile_name => @repository.profile.to_param
    assert_response :forbidden
    assert_equal profiles(:dexter), @repository.reload.profile
  end

  test "should deny access to guests" do
    set_session_current_user nil
    
    get :show, :repo_name => @repository.to_param,
               :profile_name => @repository.profile.to_param
    assert_response :forbidden
    
    get :edit, :repo_name => @repository.to_param,
               :profile_name => @repository.profile.to_param
    assert_response :forbidden
    
    put :update, :repository => @repository.attributes,
        :repo_name => @repository.to_param,
        :profile_name => @repository.profile.to_param
    assert_response :forbidden
    
    assert_no_difference 'Repository.count' do
      delete :destroy, :repo_name => @repository.to_param,
                       :profile_name => @repository.profile.to_param
    end
    assert_response :forbidden
  end  
  
  test "check_access allows author to push" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, :format => 'json',
         :repo_path => @repository.ssh_path,
         :ssh_key_id => @author_key.to_param,
         :commit_access => true.to_param
    assert_equal @repository, assigns(:repository)
    assert_equal @author, assigns(:user)
    assert_equal true, assigns(:commit_access)
    assert_equal true, JSON.parse(response.body)['access']
  end

  test "check_access allows author to pull" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, :format => 'json',
         :repo_path => @repository.ssh_path,
         :ssh_key_id => @author_key.to_param,
         :commit_access => false.to_param
    assert_equal false, assigns(:commit_access)
    assert_equal true, JSON.parse(response.body)['access']
  end

  test "check_access does not allow another user to push" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, :format => 'json',
         :repo_path => @repository.ssh_path,
         :ssh_key_id => @reader_key.to_param,
         :commit_access => true.to_param

    assert_equal @repository, assigns(:repository)
    assert_equal @reader, assigns(:user)
    assert_equal true, assigns(:commit_access)
    assert_equal false, JSON.parse(response.body)['access']
    assert_not_nil JSON.parse(response.body)['message']
  end

  test "check_access allows another user to pull" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, :format => 'json',
         :repo_path => @repository.ssh_path,
         :ssh_key_id => @reader_key.to_param,
         :commit_access => false.to_param
    assert_equal false, assigns(:commit_access)
    assert_equal true, JSON.parse(response.body)['access']
  end
  
  test "check_access rejects bad ssh key" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, :format => 'json',
         :repo_path => @repository.ssh_path,
         :ssh_key_id => 0,
         :commit_access => true.to_param
    assert_equal false, JSON.parse(response.body)['access']
  end
  
  test "check_access rejects bad repo path" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, :format => 'json',
         :repo_path => 'no/repository/here.git',
         :ssh_key_id => @author_key.to_param,
         :commit_access => true.to_param
    assert_equal false, JSON.parse(response.body)['access']
  end
  

  test "repository routes" do
    assert_routing({:path => '/_/repositories', :method => :get},
                   {:controller => 'repositories', :action => 'index'})
    assert_routing({:path => '/_/repositories/new', :method => :get},
                   {:controller => 'repositories', :action => 'new'})
    assert_routing({:path => '/_/repositories', :method => :post},
                   {:controller => 'repositories', :action => 'create'})

    assert_routing({:path => '/costan/rails', :method => :get},
                   {:controller => 'repositories', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_recognizes({:controller => 'repositories', :action => 'show',
                       :profile_name => 'costan', :repo_name => 'rails'},
                      {:path => '/_/repositories/costan/rails',
                       :method => :get})
    assert_routing({:path => '/costan/rails/edit',
                    :method => :get},
                   {:controller => 'repositories', :action => 'edit',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_recognizes({:controller => 'repositories', :action => 'edit',
                       :profile_name => 'costan', :repo_name => 'rails'},
                      {:path => '/_/repositories/costan/rails/edit',
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
  
    assert_routing({:path => '/_/check_access.json', :method => :get},
                   {:controller => 'repositories', :action => 'check_access',
                    :format => 'json'})
    assert_routing({:path => '/_/change_notice.json', :method => :post},
                   {:controller => 'repositories', :action => 'change_notice',
                    :format => 'json'})
  end
end
