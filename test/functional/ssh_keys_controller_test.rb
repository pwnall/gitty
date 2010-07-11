require 'test_helper'

class SshKeysControllerTest < ActionController::TestCase
  setup do
    @ssh_key = ssh_keys(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ssh_keys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ssh_key" do
    assert_difference('SshKey.count') do
      post :create, :ssh_key => @ssh_key.attributes
    end

    assert_redirected_to ssh_key_path(assigns(:ssh_key))
  end

  test "should show ssh_key" do
    get :show, :id => @ssh_key.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ssh_key.to_param
    assert_response :success
  end

  test "should update ssh_key" do
    put :update, :id => @ssh_key.to_param, :ssh_key => @ssh_key.attributes
    assert_redirected_to ssh_key_path(assigns(:ssh_key))
  end

  test "should destroy ssh_key" do
    assert_difference('SshKey.count', -1) do
      delete :destroy, :id => @ssh_key.to_param
    end

    assert_redirected_to ssh_keys_path
  end
end
