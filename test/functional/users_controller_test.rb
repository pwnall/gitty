require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
    admin = users(:jane)

    User.class_eval do
      (class <<self; self; end).class_eval do      
        alias_method :real_can_list_users?, :can_list_users?
        define_method :can_list_users? do |user|
          user == admin
        end
      end
    end
  end
  
  teardown do
    User.class_eval do
      (class <<self; self; end).class_eval do
        undef can_list_users?
        alias_method :can_list_users?, :real_can_list_users?
        undef real_can_list_users?
      end
    end    
  end

  test "should get index" do
    set_session_current_user users(:jane)
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    attributes = { :email => 'john2@gmail.com', :password => 'passw0rd',
                   :password_confirmation => 'passw0rd'}
    assert_difference('User.count') do
      post :create, :user => attributes
    end

    assert_equal assigns(:user), session_current_user
    assert_redirected_to session_path
  end

  test "should show user" do
    set_session_current_user users(:john)
    get :show, :user_param => @user.to_param
    assert_response :success
  end

  test "should destroy user" do
    set_session_current_user users(:john)
    assert_difference('User.count', -1) do
      delete :destroy, :user_param => @user.to_param
    end

    assert_redirected_to users_path
  end
  
  test "another user should not be able to change account" do
    set_session_current_user users(:jane)

    get :show, :user_param => @user.to_param
    assert_response :forbidden

    assert_no_difference 'User.count' do
      delete :destroy, :user_param => @user.to_param
    end
    assert_response :forbidden
  end
  
  test "random users should not be able to list accounts" do
    set_session_current_user users(:john)
    get :index
    assert_response :forbidden
  end
end
