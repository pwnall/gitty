require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup do
    @profile = profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profile" do
    assert_difference('Profile.count') do
      post :create, :profile => @profile.attributes
    end

    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should show profile" do
    get :show, :id => @profile.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @profile.to_param
    assert_response :success
  end

  test "should update profile" do
    put :update, :id => @profile.to_param, :profile => @profile.attributes
    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should destroy profile" do
    assert_difference('Profile.count', -1) do
      delete :destroy, :id => @profile.to_param
    end

    assert_redirected_to profiles_path
  end
end
