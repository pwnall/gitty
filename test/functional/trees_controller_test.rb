require 'test_helper'

class TreesControllerTest < ActionController::TestCase
  setup do
    @tree = trees(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trees)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tree" do
    assert_difference('Tree.count') do
      post :create, :tree => @tree.attributes
    end

    assert_redirected_to tree_path(assigns(:tree))
  end

  test "should show tree" do
    get :show, :id => @tree.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @tree.to_param
    assert_response :success
  end

  test "should update tree" do
    put :update, :id => @tree.to_param, :tree => @tree.attributes
    assert_redirected_to tree_path(assigns(:tree))
  end

  test "should destroy tree" do
    assert_difference('Tree.count', -1) do
      delete :destroy, :id => @tree.to_param
    end

    assert_redirected_to trees_path
  end
end
