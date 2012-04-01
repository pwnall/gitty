require 'test_helper'

class IssuesControllerTest < ActionController::TestCase
  setup do
    @issue = issues(:costan_ghost_translated)
    @author = users(:jane)
    
    set_session_current_user @author    
  end

  test "should get index" do
    get :index, :profile_name => @issue.repository.profile,
                :repo_name => @issue.repository
    assert_response :success
    assert_not_nil assigns(:issues)
  end

  test "should get new" do
    get :new, :profile_name => @issue.repository.profile,
              :repo_name => @issue.repository
    assert_response :success
  end

  test "should create issue" do
    assert_difference('Issue.count') do
      post :create, :profile_name => @issue.repository.profile,
                    :repo_name => @issue.repository, :issue => @issue.attributes
    end

    assert_redirected_to profile_repository_issues_path(
        assigns(:issue).repository.profile, assigns(:issue).repository)
  end

  test "should show issue" do
    get :show, :profile_name => @issue.repository.profile,
               :repo_name => @issue.repository, :id => @issue
    assert_response :success
  end

  test "should get edit" do
    get :edit, :profile_name => @issue.repository.profile,
               :repo_name => @issue.repository, :id => @issue
    assert_response :success
  end

  test "should update issue" do
    put :update, :profile_name => @issue.repository.profile,
                 :repo_name => @issue.repository, :id => @issue,
                 :issue => @issue.attributes
    assert_redirected_to profile_repository_issues_path(
        assigns(:issue).repository.profile, assigns(:issue).repository)
  end

  test "should destroy issue" do
    assert_difference('Issue.count', -1) do
      delete :destroy, :profile_name => @issue.repository.profile,
                       :repo_name => @issue.repository, :id => @issue
    end

    assert_redirected_to issues_path
  end
  
  # TODO(christy13): tests for no logged-in user
  
  # TODO(christy13): routing tests
end
