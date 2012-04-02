require 'test_helper'

class IssuesControllerTest < ActionController::TestCase
  setup do
<<<<<<< HEAD
    @issue = issues(:one)
  end

  test "should get index" do
    get :index
=======
    @issue = issues(:costan_ghost_translated)
    @author = users(:jane)
    
    set_session_current_user @author    
  end

  test "should get index" do
    get :index, :profile_name => @issue.repository.profile,
                :repo_name => @issue.repository
>>>>>>> 8c3dcedaea6189a4bfae7601e81763de2cd9bcc4
    assert_response :success
    assert_not_nil assigns(:issues)
  end

  test "should get new" do
<<<<<<< HEAD
    get :new
=======
    get :new, :profile_name => @issue.repository.profile,
              :repo_name => @issue.repository
>>>>>>> 8c3dcedaea6189a4bfae7601e81763de2cd9bcc4
    assert_response :success
  end

  test "should create issue" do
    assert_difference('Issue.count') do
<<<<<<< HEAD
      post :create, issue: @issue.attributes
    end

    assert_redirected_to issue_path(assigns(:issue))
  end

  test "should show issue" do
    get :show, id: @issue
=======
      post :create, :profile_name => @issue.repository.profile,
                    :repo_name => @issue.repository, :issue => @issue.attributes
    end

    assert_redirected_to profile_repository_issues_path(
        assigns(:issue).repository.profile, assigns(:issue).repository)
  end

  test "should show issue" do
    get :show, :profile_name => @issue.repository.profile,
               :repo_name => @issue.repository, :id => @issue
>>>>>>> 8c3dcedaea6189a4bfae7601e81763de2cd9bcc4
    assert_response :success
  end

  test "should get edit" do
<<<<<<< HEAD
    get :edit, id: @issue
=======
    get :edit, :profile_name => @issue.repository.profile,
               :repo_name => @issue.repository, :id => @issue
>>>>>>> 8c3dcedaea6189a4bfae7601e81763de2cd9bcc4
    assert_response :success
  end

  test "should update issue" do
<<<<<<< HEAD
    put :update, id: @issue, issue: @issue.attributes
    assert_redirected_to issue_path(assigns(:issue))
=======
    put :update, :profile_name => @issue.repository.profile,
                 :repo_name => @issue.repository, :id => @issue,
                 :issue => @issue.attributes
    assert_redirected_to profile_repository_issues_path(
        assigns(:issue).repository.profile, assigns(:issue).repository)
>>>>>>> 8c3dcedaea6189a4bfae7601e81763de2cd9bcc4
  end

  test "should destroy issue" do
    assert_difference('Issue.count', -1) do
<<<<<<< HEAD
      delete :destroy, id: @issue
=======
      delete :destroy, :profile_name => @issue.repository.profile,
                       :repo_name => @issue.repository, :id => @issue
>>>>>>> 8c3dcedaea6189a4bfae7601e81763de2cd9bcc4
    end

    assert_redirected_to issues_path
  end
<<<<<<< HEAD
=======
  
  # TODO(christy13): tests for no logged-in user
  
  # TODO(christy13): routing tests
>>>>>>> 8c3dcedaea6189a4bfae7601e81763de2cd9bcc4
end
