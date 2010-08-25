require 'test_helper'

class SessionControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
  end
  
  test "user home page" do
    set_session_current_user @user
    get :show
    
    assert_equal @user, assigns(:user)
    assert_select 'a', 'Log out'
  end
  
  test "application welcome page" do
    get :show
    
    assert_equal User.count, assigns(:stats)[:users], 'users'
    assert_equal Repository.count, assigns(:stats)[:repositories], 'repos'
    assert_equal Commit.count, assigns(:stats)[:commits], 'commits'
    assert_equal Blob.count, assigns(:stats)[:files], 'files'
    assert_select 'a', 'Log in'
  end
end
