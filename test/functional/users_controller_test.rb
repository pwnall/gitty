require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:costan)
    admin = users(:dexter)

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
    set_session_current_user users(:dexter)
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    ActionMailer::Base.deliveries = []
    attributes = { :email => 'costan2@gmail.com', :password => 'passw0rd',
                   :password_confirmation => 'passw0rd'}
    assert_difference 'User.count' do
      assert_difference 'Tokens::EmailVerification.count', 1,
                        'E-mail verification token' do
        post :create, :user => attributes
      end
    end
    assert_redirected_to new_session_path

    assert_nil session_current_user,
               "A new user should not be logged in without e-mail verification"
    assert !assigns(:user).email_credential.verified?,
           "A new user's e-mail should not be verified"
    assert !ActionMailer::Base.deliveries.empty?,
           "E-mail verification e-mail not sent"
  end

  test "should create user when email checking is disabled" do
    ConfigVar['signup.email_check'] = 'disabled'
    ActionMailer::Base.deliveries = []
    attributes = { :email => 'costan2@gmail.com', :password => 'passw0rd',
                   :password_confirmation => 'passw0rd'}
    assert_difference 'User.count' do
      assert_no_difference 'Tokens::EmailVerification.count',
                           'No e-mail verification token' do
        post :create, :user => attributes
      end
    end

    assert_redirected_to root_url
    assert_equal session_current_user, assigns(:user),
           'The new user should be logged on'
    assert assigns(:user).email_credential.verified?,
           "The new user's e-mail should be verified"
    assert ActionMailer::Base.deliveries.empty?,
           "No verification e-mail"
  end

  test "should show user" do
    set_session_current_user users(:costan)
    get :show, :user_param => @user.to_param
    assert_response :success
  end

  test "should destroy user" do
    set_session_current_user users(:costan)
    assert_difference('User.count', -1) do
      delete :destroy, :user_param => @user.to_param
    end

    assert_redirected_to users_path
  end

  test "another user should not be able to change account" do
    set_session_current_user users(:dexter)

    get :show, :user_param => @user.to_param
    assert_response :forbidden

    assert_no_difference 'User.count' do
      delete :destroy, :user_param => @user.to_param
    end
    assert_response :forbidden
  end

  test "random users should not be able to list accounts" do
    set_session_current_user users(:costan)
    get :index
    assert_response :forbidden
  end
end
