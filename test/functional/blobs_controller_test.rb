require 'test_helper'

class BlobsControllerTest < ActionController::TestCase
  setup do
    @blob = blobs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:blobs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create blob" do
    assert_difference('Blob.count') do
      post :create, :blob => @blob.attributes
    end

    assert_redirected_to blob_path(assigns(:blob))
  end

  test "should show blob" do
    get :show, :id => @blob.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @blob.to_param
    assert_response :success
  end

  test "should update blob" do
    put :update, :id => @blob.to_param, :blob => @blob.attributes
    assert_redirected_to blob_path(assigns(:blob))
  end

  test "should destroy blob" do
    assert_difference('Blob.count', -1) do
      delete :destroy, :id => @blob.to_param
    end

    assert_redirected_to blobs_path
  end
end
