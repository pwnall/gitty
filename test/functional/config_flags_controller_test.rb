require 'test_helper'

class ConfigFlagsControllerTest < ActionController::TestCase
  setup do
    @config_flag = config_flags(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:config_flags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create config_flag" do
    assert_difference('ConfigFlag.count') do
      post :create, :config_flag => @config_flag.attributes
    end

    assert_redirected_to config_flag_path(assigns(:config_flag))
  end

  test "should show config_flag" do
    get :show, :id => @config_flag.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @config_flag.to_param
    assert_response :success
  end

  test "should update config_flag" do
    put :update, :id => @config_flag.to_param, :config_flag => @config_flag.attributes
    assert_redirected_to config_flag_path(assigns(:config_flag))
  end

  test "should destroy config_flag" do
    assert_difference('ConfigFlag.count', -1) do
      delete :destroy, :id => @config_flag.to_param
    end

    assert_redirected_to config_flags_path
  end
end
