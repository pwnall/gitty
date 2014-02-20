require 'test_helper'

class RepositoriesControllerTest < ActionController::TestCase
  setup :mock_profile_paths
  teardown :mock_profile_paths_undo

  setup do
    @repository = repositories(:dexter_ghost)
    @author = users(:dexter)
    @author_key = @author.ssh_keys.first
    @reader = users(:costan)
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
    attributes = @repository.attributes.with_indifferent_access.
        except!(:id, :profile_id, :created_at, :updated_at).
        merge name: 'rails', profile_name: @repository.profile.name
    assert_difference('Repository.count') do
      assert_difference('FeedItem.count') do
        post :create, repository: attributes
      end
    end
    assert_equal [@author.profile], assigns(:repository).subscribers

    assert_redirected_to profile_repository_path(assigns(:repository).profile,
                                                 assigns(:repository))
    item = FeedItem.last
    assert_equal 'new_repository', item.verb
    assert_equal @author.profile, item.author
    assert_equal assigns(:repository), item.target
  end

  test "should create repository with extra form input" do
    attributes = @repository.attributes.with_indifferent_access.
        except!(:id, :profile_id, :created_at, :updated_at).
        merge name: 'rails', profile_name: @repository.profile.name
    assert_difference('Repository.count') do
      post :create, repository: attributes, utf8: "\u2713",
                    commit: 'Create Repository'
    end
    assert_redirected_to profile_repository_path(assigns(:repository).profile,
                                                 assigns(:repository))
  end

  test "should show repository" do
    get :show, repo_name: @repository.to_param,
               profile_name: @repository.profile.to_param
    assert_response :success
  end

  test "should show repository with a README" do
    mock_any_repository_path

    tree = @repository.default_branch.commit.tree
    TreeEntry.create! tree: tree, name: 'README.rb',
                      child: blobs(:lib_ghost_rb)
    get :show, repo_name: @repository.to_param,
               profile_name: @repository.profile.to_param
    assert_response :success
  end


  test "should show public repository without logged in user" do
    set_session_current_user nil
    get :show, repo_name: repositories(:public_ghost).to_param,
               profile_name: repositories(:public_ghost).profile.to_param
    assert_response :success
  end

  test "should show git directions to author for empty repository" do
    repository = repositories(:costan_ghost)
    set_session_current_user users(:costan)
    get :show, repo_name: repository.to_param,
               profile_name: repository.profile.to_param
    assert_response :success
    assert_select '.bootstrap_steps'
  end

  test "should show oops page to non-committer for empty repository" do
    repository = repositories(:costan_ghost)
    set_session_current_user users(:dexter)
    AclEntry.set(users(:dexter).profile, repository, :read)

    get :show, repo_name: repository.to_param,
               profile_name: repository.profile.to_param
    assert_response :success
    assert_select '.empty_repository'
  end

  test "should get edit" do
    get :edit, repo_name: @repository.to_param,
               profile_name: @repository.profile.to_param
    assert_response :success
  end

  test "should update repository" do
    attributes = @repository.attributes.with_indifferent_access.
        except!(:id, :profile_id, :created_at, :updated_at).
        merge profile_name: @repository.profile.name

    patch :update, repository: attributes,
          repo_name: @repository.to_param,
          profile_name: @repository.profile.to_param

    assert_redirected_to profile_repository_path(assigns(:repository).profile,
                                                 assigns(:repository))
  end

  test "should rename repository" do
    old_local_path = @repository.local_path
    FileUtils.mkdir_p old_local_path
    attributes = @repository.attributes.with_indifferent_access.
        except!(:id, :profile_id, :created_at, :updated_at).
        merge profile_name: @repository.profile.name, name: 'randomness'

    patch :update, repository: attributes,
          repo_name: @repository.to_param,
          profile_name: @repository.profile.to_param

    assert_equal 'randomness', @repository.reload.name

    assert_not_equal old_local_path, @repository.local_path,
                     'rename test case broken'
    assert !File.exist?(old_local_path), 'repository not renamed'
    assert File.exist?(@repository.local_path), 'repository not renamed'

    assert_redirected_to profile_repository_path(assigns(:repository).profile,
                                                 assigns(:repository))
  end

  test "should move repository to different profile" do
    old_local_path = @repository.local_path
    FileUtils.mkdir_p old_local_path
    profile = profiles(:mit)
    AclEntry.set @author, profile, :charge

    attributes = @repository.attributes.with_indifferent_access.
        except!(:id, :profile_id, :created_at, :updated_at).
        merge profile_name: profile.to_param
    patch :update, repository: attributes,
          repo_name: @repository.to_param,
          profile_name: @repository.profile.to_param

    assert_equal profile, @repository.reload.profile

    assert_not_equal old_local_path, @repository.local_path,
                     'rename test case broken'
    assert !File.exist?(old_local_path), 'repository not renamed'
    assert File.exist?(@repository.local_path), 'repository not renamed'

    assert_redirected_to profile_repository_path(profile,
                                                 assigns(:repository))
  end

  test "should reject repository move to profile without charge bits" do
    profile = profiles(:mit)

    attributes = @repository.attributes.with_indifferent_access.
        except!(:id, :profile_id, :created_at, :updated_at).
        merge profile_name: profile.to_param
    patch :update, repository: attributes,
          repo_name: @repository.to_param,
          profile_name: @repository.profile.to_param

    assert_response :forbidden
  end

  test "should use old repository url on rejected rename" do
    attributes = @repository.attributes.with_indifferent_access.
        except!(:id, :profile_id, :created_at, :updated_at).
        merge profile_name: @repository.profile.name, name: '-broken'

    patch :update, repository: attributes,
          repo_name: @repository.to_param,
          profile_name: @repository.profile.to_param

    assert_not_equal '-broken', @repository.reload.name
    repo_path = profile_repository_path(@repository.profile, @repository)
    assert_template :edit
    assert_select "form[action=#{repo_path}]"
    assert_select 'input[id=repository_name][value="-broken"]'
  end

  test "should destroy repository" do
    assert_difference 'Repository.count', -1 do
      assert_difference 'FeedItem.count' do
        delete :destroy, repo_name: @repository.to_param,
                         profile_name: @repository.profile.to_param
      end
    end

    assert_redirected_to repositories_url

    item = FeedItem.last
    assert_equal 'del_repository', item.verb
    assert_equal @author.profile, item.author
    assert_equal @repository.name, item.data[:repository_name]
  end

  test "should grant read access to participating user" do
    set_session_current_user users(:costan)
    AclEntry.set(users(:costan).profile, @repository, :participate)

    get :show, repo_name: @repository.to_param,
               profile_name: @repository.profile.to_param
    assert_response :success

    get :edit, repo_name: @repository.to_param,
               profile_name: @repository.profile.to_param
    assert_response :forbidden

    patch :update, repository: @repository.attributes,
          repo_name: @repository.to_param,
          profile_name: @repository.profile.to_param
    assert_response :forbidden

    assert_no_difference 'Repository.count' do
      delete :destroy, repo_name: @repository.to_param,
                       profile_name: @repository.profile.to_param
    end
    assert_response :forbidden
  end

  test "should reject unauthorized charging via create" do
    attributes = @repository.attributes.merge name: 'rails',
        profile_name: 'costan'
    assert_no_difference 'Repository.count' do
      post :create, repository: attributes
    end
    assert_response :forbidden
  end

  test "should reject unauthorized charging via update" do
    attributes = @repository.attributes.merge profile_name: 'costan'
    patch :update, repository: attributes, repo_name: @repository.to_param,
          profile_name: @repository.profile.to_param
    assert_response :forbidden
    assert_equal profiles(:dexter), @repository.reload.profile
  end

  test "should deny access to guests" do
    set_session_current_user nil

    get :show, repo_name: @repository.to_param,
               profile_name: @repository.profile.to_param
    assert_response :forbidden

    get :edit, repo_name: @repository.to_param,
               profile_name: @repository.profile.to_param
    assert_response :forbidden

    patch :update, repository: @repository.attributes,
                   repo_name: @repository.to_param,
                   profile_name: @repository.profile.to_param
    assert_response :forbidden

    assert_no_difference 'Repository.count' do
      delete :destroy, repo_name: @repository.to_param,
                       profile_name: @repository.profile.to_param
    end
    assert_response :forbidden

    get :feed, repo_name: @repository.to_param,
               profile_name: @repository.profile.to_param
    assert_response :forbidden
  end

  test "check_access allows author to push" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, format: 'json', repo_path: @repository.ssh_path,
                                        ssh_key_id: @author_key.to_param,
                                        commit_access: true.to_param
    assert_equal @repository, assigns(:repository)
    assert_equal @author, assigns(:user)
    assert_equal true, assigns(:commit_access)
    assert_equal true, JSON.parse(response.body)['access']
  end

  test "check_access allows author to pull" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, format: 'json', repo_path: @repository.ssh_path,
                                        ssh_key_id: @author_key.to_param,
                                        commit_access: false.to_param
    assert_equal false, assigns(:commit_access)
    assert_equal true, JSON.parse(response.body)['access']
  end

  test "check_access does not allow random user to push" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, format: 'json', repo_path: @repository.ssh_path,
                                        ssh_key_id: @reader_key.to_param,
                                        commit_access: true.to_param

    assert_equal @repository, assigns(:repository)
    assert_equal @reader, assigns(:user)
    assert_equal true, assigns(:commit_access)
    assert_equal false, JSON.parse(response.body)['access']
    assert_not_nil JSON.parse(response.body)['message']
  end

  test "check_access allows another user to pull" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, format: 'json', repo_path: @repository.ssh_path,
                                        ssh_key_id: @reader_key.to_param,
                                        commit_access: false.to_param
    assert_equal false, assigns(:commit_access)
    assert_equal true, JSON.parse(response.body)['access']
  end

  test "check_access rejects bad ssh key" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, format: 'json', repo_path: @repository.ssh_path,
                                        ssh_key_id: 0,
                                        commit_access: true.to_param
    assert_equal false, JSON.parse(response.body)['access']
  end

  test "check_access rejects bad repo path" do
    # NOTE: the test should use GET, except GET doesn't encode extra parameters
    post :check_access, format: 'json', repo_path: 'no/repository/here.git',
                                        ssh_key_id: @author_key.to_param,
                                        commit_access: true.to_param
    assert_equal false, JSON.parse(response.body)['access']
  end

  test "change_notice works for author" do
    set_session_current_user nil
    mock_any_repository_path
    assert_difference 'Tag.count', 1 do
      assert_difference 'FeedItem.count', 7 do
        post :change_notice, format: 'json', repo_path: @repository.ssh_path,
                                             ssh_key_id: @author_key.to_param
      end
    end
    assert_response :success
  end

  test "should show feed" do
    get :feed, repo_name: @repository.to_param,
               profile_name: @repository.profile.to_param
    assert_response :success
  end

  test "repository routes" do
    assert_routing({path: '/_/repositories', method: :get},
                   {controller: 'repositories', action: 'index'})
    assert_routing({path: '/_/repositories/new', method: :get},
                   {controller: 'repositories', action: 'new'})
    assert_routing({path: '/_/repositories', method: :post},
                   {controller: 'repositories', action: 'create'})

    assert_routing({path: '/costan/rails', method: :get},
                   {controller: 'repositories', action: 'show',
                    profile_name: 'costan', repo_name: 'rails'})
    assert_recognizes({controller: 'repositories', action: 'show',
                       profile_name: 'costan', repo_name: 'rails'},
                      {path: '/_/repositories/costan/rails',
                       method: :get})
    assert_routing({path: '/costan/rails/edit', method: :get},
                   {controller: 'repositories', action: 'edit',
                    profile_name: 'costan', repo_name: 'rails'})
    assert_recognizes({controller: 'repositories', action: 'edit',
                       profile_name: 'costan', repo_name: 'rails'},
                      {path: '/_/repositories/costan/rails/edit',
                       method: :get})
    assert_routing({path: '/costan/rails', method: :patch},
                   {controller: 'repositories', action: 'update',
                    profile_name: 'costan', repo_name: 'rails'})
    assert_recognizes({controller: 'repositories', action: 'update',
                       profile_name: 'costan', repo_name: 'rails'},
                      {path: '/_/repositories/costan/rails',
                       method: :patch})
    assert_routing({path: '/costan/rails', method: :delete},
                   {controller: 'repositories', action: 'destroy',
                    profile_name: 'costan', repo_name: 'rails'})
    assert_recognizes({controller: 'repositories', action: 'destroy',
                       profile_name: 'costan', repo_name: 'rails'},
                      {path: '/_/repositories/costan/rails',
                       method: :delete})

    assert_routing({path: '/_/check_access.json', method: :get},
                   {controller: 'repositories', action: 'check_access',
                    format: 'json'})
    assert_routing({path: '/_/change_notice.json', method: :post},
                   {controller: 'repositories', action: 'change_notice',
                    format: 'json'})

    assert_routing({path: '/costan/rails/feed', method: :get},
                   {controller: 'repositories', action: 'feed',
                    profile_name: 'costan', repo_name: 'rails'})
  end

  test "special characters in repository names" do
    assert_routing({path: '/co.st-an_/r-ai_l.s', method: :get},
                   {controller: 'repositories', action: 'show',
                    profile_name: 'co.st-an_', repo_name: 'r-ai_l.s'})
  end
end
