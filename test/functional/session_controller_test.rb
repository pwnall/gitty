require 'test_helper'

class SessionControllerTest < ActionController::TestCase
  setup do
    @user = users(:costan)
    @email_credential = credentials(:costan_email)
    @password_credential = credentials(:costan_password)
    @token_credential = credentials(:costan_email_token)
  end

  test "user home page" do
    set_session_current_user @user
    get :show

    assert_equal @user, assigns(:user)
    assert_equal @user.profile, assigns(:profile)
    assert_select 'a[href="/_/session"][data-method="delete"]', 'Log out'
  end

  test "user home page for user without profile" do
    user = users(:disconnected)
    set_session_current_user user
    get :show

    assert_equal user.email, assigns(:profile).display_email
  end

  test "user login works and purges old sessions" do
    old_token = credentials(:costan_session_token)
    old_token.updated_at = Time.now - 1.year
    old_token.save!
    email_credential = credentials(:dexter_email)
    post :create, email: email_credential.email, password: 'pa55w0rd'
    assert_redirected_to session_url
    assert_equal users(:dexter), session_current_user, 'session'
    assert_nil Tokens::Base.with_code(old_token.code).first,
               'old session not purged'
  end

  test "user logged in JSON request" do
    set_session_current_user @user
    get :show, format: 'json'

    assert_equal @user.exuid,
        ActiveSupport::JSON.decode(response.body)['user']['exuid']
  end

  test "application welcome page" do
    get :show

    assert_equal User.count, assigns(:stats)[:users], 'users'
    assert_equal Repository.count, assigns(:stats)[:repositories], 'repos'
    assert_equal Commit.count, assigns(:stats)[:commits], 'commits'
    assert_equal Blob.count, assigns(:stats)[:files], 'files'
    assert_select 'a', 'Log in'
  end

  test "user not logged in with JSON request" do
    get :show, format: 'json'

    assert_equal({}, ActiveSupport::JSON.decode(response.body))
  end

  test "user login page" do
    get :new
    assert_template :new

    assert_select 'form[action=?]', session_path do
      assert_select 'input[name=?]', 'session[email]'
      assert_select 'input[name=?]', 'session[password]'
      assert_select 'button[name="login"]'
      assert_select 'button[name="reset_password"]'
    end
  end

  test "e-mail verification link" do
    get :token, code: @token_credential.code
    assert_redirected_to session_url
    assert @email_credential.reload.verified?, 'Email not verified'
  end

  test "password reset link" do
    password_credential = credentials(:dexter_password)
    get :token, code: credentials(:dexter_password_token).code
    assert_redirected_to change_password_session_url
    assert_nil Credential.where(id: password_credential.id).first,
               'Password not cleared'
  end

  test "password change form" do
    set_session_current_user @user
    get :password_change

    assert_select 'span[class="password_age"]'
    assert_select 'form[action=?][method="post"]',
                  change_password_session_path do
      assert_select 'input[name="old_password"]'
      assert_select 'input[name=?]', 'credential[password]'
      assert_select 'input[name=?]', 'credential[password_confirmation]'
      assert_select 'input[type=submit]'
    end
  end

  test "password reset form" do
    set_session_current_user @user
    @password_credential.destroy
    get :password_change

    assert_select 'span[class="password_age"]', count: 0
    assert_select 'form[action=?][method="post"]',
                  change_password_session_path do
      assert_select 'input[name="old_password"]', count: 0
      assert_select 'input[name=?]', 'credential[password]'
      assert_select 'input[name=?]', 'credential[password_confirmation]'
      assert_select 'input[type=submit]'
    end
  end

  test "password reset request" do
    ActionMailer::Base.deliveries = []

    assert_difference 'Credential.count', 1 do
      post :reset_password, session: { email: @email_credential.email }
    end

    assert !ActionMailer::Base.deliveries.empty?, 'email generated'
    email = ActionMailer::Base.deliveries.last
    assert_equal [@email_credential.email], email.to

    assert_redirected_to new_session_url
  end
end
