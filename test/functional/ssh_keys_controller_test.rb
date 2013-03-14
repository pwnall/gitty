require 'test_helper'

class SshKeysControllerTest < ActionController::TestCase
  setup :mock_ssh_keys_path

  setup do
    @ssh_key = ssh_keys(:rsa)
    set_session_current_user @ssh_key.user

    key_path = Rails.root.join 'test', 'fixtures', 'ssh_keys', 'new_key.pub'
    @new_ssh_key_line = File.read key_path
  end

  test "should get index" do
    get :index
    assert_redirected_to session_url
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ssh_key" do
    attributes = { :name => @ssh_key.name, :key_line => @new_ssh_key_line }
    assert_difference('SshKey.count') do
      post :create, :ssh_key => attributes
    end

    assert_redirected_to ssh_key_path(assigns(:ssh_key))
  end

  test "should show ssh_key text" do
    get :show, :id => @ssh_key.to_param, :format => 'txt'
    assert_response :success
    assert_equal @ssh_key.key_line, response.body
  end

  test "should show ssh key" do
    get :show, :id => @ssh_key.to_param
    assert_redirected_to session_url
  end

  test "should get edit" do
    get :edit, :id => @ssh_key.to_param
    assert_response :success
  end

  test "should update ssh_key" do
    put :update, :id => @ssh_key.to_param,
        :ssh_key => @ssh_key.attributes.with_indifferent_access.
                             slice(:name, :key_line)

    assert_redirected_to ssh_key_path(assigns(:ssh_key))
  end

  test "should destroy ssh_key" do
    assert_difference 'SshKey.count', -1 do
      delete :destroy, :id => @ssh_key.to_param
    end

    assert_redirected_to ssh_keys_path
  end

  test "should deny access to non-owner" do
    non_owner = User.all.find { |u| u != @ssh_key.user }
    assert non_owner, 'non-owner finding failed'
    set_session_current_user non_owner

    get :show, :id => @ssh_key.to_param
    assert_response :forbidden, 'show'

    get :edit, :id => @ssh_key.to_param
    assert_response :forbidden, 'edit'

    put :update, :id => @ssh_key.to_param, :ssh_key => @ssh_key.attributes
    assert_response :forbidden, 'update'

    assert_no_difference('SshKey.count') do
      delete :destroy, :id => @ssh_key.to_param
      assert_response :forbidden, 'destroy'
    end
  end

  test "should deny access to guests" do
    set_session_current_user nil

    get :show, :id => @ssh_key.to_param
    assert_response :forbidden, 'show'

    get :edit, :id => @ssh_key.to_param
    assert_response :forbidden, 'edit'

    put :update, :id => @ssh_key.to_param, :ssh_key => @ssh_key.attributes
    assert_response :forbidden, 'update'

    assert_no_difference('SshKey.count') do
      delete :destroy, :id => @ssh_key.to_param
      assert_response :forbidden, 'destroy'
    end
  end
end
