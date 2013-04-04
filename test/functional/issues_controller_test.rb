require 'test_helper'

class IssuesControllerTest < ActionController::TestCase
  setup do
    @issue = issues(:costan_ghost_translated)
    @repository = @issue.repository
    @author = users(:costan)

    set_session_current_user @author
  end

  test "should get index" do
    get :index, profile_name: @issue.repository.profile,
                repo_name: @issue.repository
    assert_response :success
    assert_equal @repository, assigns(:repository)
    assert_not_nil assigns(:issues)
  end

  test "should get new" do
    get :new, profile_name: @issue.repository.profile,
              repo_name: @issue.repository
    assert_response :success
  end

  test "should create issue" do
    assert_difference('Issue.count') do
      post :create, profile_name: @issue.repository.profile,
           repo_name: @issue.repository,
           issue: @issue.attributes.with_indifferent_access.
          except!(:id, :created_at, :updated_at, :author_id, :repository_id,
                 :number)
    end

    assert_redirected_to profile_repository_issues_path(
        assigns(:issue).repository.profile, assigns(:issue).repository)
  end

  test "should show issue" do
    get :show, profile_name: @issue.repository.profile,
        repo_name: @issue.repository, issue_number: @issue.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, profile_name: @issue.repository.profile,
        repo_name: @issue.repository, issue_number: @issue.to_param
    assert_response :success
  end

  test "should update issue" do
    put :update, profile_name: @issue.repository.profile,
        repo_name: @issue.repository, issue_number: @issue.to_param,
        issue: @issue.attributes.with_indifferent_access.
        except!(:id, :created_at, :updated_at, :author_id, :repository_id,
                :number)
    assert_redirected_to profile_repository_issues_path(
        assigns(:issue).repository.profile, assigns(:issue).repository)
  end

  test "should destroy issue" do
    assert_difference('Issue.count', -1) do
      delete :destroy, profile_name: @issue.repository.profile,
                       repo_name: @issue.repository, issue_number: @issue
    end

    assert_redirected_to issues_path
  end

  test "should get index issues only for this repo" do
    get :index, profile_name: @issue.repository.profile,
                repo_name: @issue.repository
    assert_response :success
    assert_equal @repository, assigns(:repository)
    assert_equal @issue, assigns(:issues).first
  end

  test "should not show the edit issue link if user isn't editor or author" do
    set_session_current_user users(:rms)
    get :show, repo_name: @issue.repository,
               profile_name: @issue.repository.profile,
               issue_number: @issue
    assert_response :forbidden
    assert_select %Q|a[href*="#{edit_profile_repository_issue_path(
        @issue.repository.profile, @issue.repository, @issue)}"]|, 0
  end

  test "should not show new issue button if user can't read repo" do
    set_session_current_user users(:rms)
    get :index, repo_name: @issue.repository,
                profile_name: @issue.repository.profile
    assert_response :forbidden
    assert_select %Q|input[value*="New Issue"]|, 0
  end

  test "should not show close issue button if user isn't editor or author" do
    set_session_current_user users(:rms)
    get :show, repo_name: @issue.repository,
               profile_name: @issue.repository.profile,
               issue_number: @issue
    assert_response :forbidden
    assert_select %Q|input[class*="close_issue_button"]|, 0
  end

  test "should not be able to open issue if user can't read repo" do
    set_session_current_user users(:rms)
    get :new, profile_name: @issue.repository.profile,
              repo_name: @issue.repository
    assert_response :forbidden
  end

  test "should not be able to close issue if user isn't an editor or author" do
    set_session_current_user users(:costan)
    issue = issues(:public_ghost_dead_code)
    put :update, profile_name: issue.repository.profile,
                 repo_name: issue.repository,
                 issue_number: issue, issue: { open: false }
    assert_response :forbidden
  end

  test "should be able to close issue if user is an editor or author" do
    set_session_current_user users(:dexter)
    issue = issues(:public_ghost_dead_code)
    put :update, profile_name: issue.repository.profile,
                 repo_name: issue.repository,
                 issue_number: issue, issue: { open: false }
    assert_equal issue.reload.open, false
  end

  test 'should not show sensitive issue if user is not an editor or author' do
    set_session_current_user users(:costan)
    issue = issues(:public_ghost_security_vulnerability)
    get :show, repo_name: issue.repository,
               profile_name: issue.repository.profile,
               issue_number: issue
    assert_response :forbidden
  end

  test 'should show sensitive issue if user is an editor or author' do
    set_session_current_user users(:dexter)
    issue = issues(:public_ghost_security_vulnerability)
    get :show, repo_name: issue.repository,
               profile_name: issue.repository.profile,
               issue_number: issue
    assert_response :success
  end

  test "issue routes" do
    assert_routing({path: "/costan/costan_ghost/issues", method: 'get'},
                   {controller: 'issues', action: 'index',
                    profile_name: 'costan',
                    repo_name: 'costan_ghost'})
    assert_routing({path: "/costan/costan_ghost/issues/new",
                    method: :get},
                   {controller: 'issues', action: 'new',
                    profile_name: 'costan',
                    repo_name: 'costan_ghost'})
    assert_routing({path: "/costan/costan_ghost/issues",
                    method: :post},
                   {controller: 'issues', action: 'create',
                    profile_name: 'costan',
                    repo_name: 'costan_ghost'})
    assert_routing({path: "/costan/costan_ghost/issues/42/edit",
                    method: :get},
                   {controller: 'issues', action: 'edit',
                    profile_name: 'costan',
                    repo_name: 'costan_ghost',
                    issue_number: '42'})
    assert_routing({path: "/costan/costan_ghost/issues/42",
                    method: :get},
                   {controller: 'issues', action: 'show',
                    profile_name: 'costan',
                    repo_name: 'costan_ghost',
                    issue_number: '42'})
    assert_routing({path: "/costan/costan_ghost/issues/42",
                    method: :put},
                   {controller: 'issues', action: 'update',
                    profile_name: 'costan',
                    repo_name: 'costan_ghost',
                    issue_number: '42'})
    assert_routing({path: "/costan/costan_ghost/issues/42",
                    method: :delete},
                   {controller: 'issues', action: 'destroy',
                    profile_name: 'costan',
                    repo_name: 'costan_ghost',
                    issue_number: '42'})
  end
end
