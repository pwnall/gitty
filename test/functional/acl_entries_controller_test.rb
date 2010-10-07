require 'test_helper'

class AclEntriesControllerTest < ActionController::TestCase
  setup do
    @repository = repositories(:dexter_ghost)
    @acl_entry = acl_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:acl_entries)
  end

  test "should create acl_entry" do
    assert_difference('AclEntry.count') do
      post :create, :acl_entry => @acl_entry.attributes
    end

    assert_redirected_to acl_entry_path(assigns(:acl_entry))
  end

  test "should show acl_entry" do
    get :show, :id => @acl_entry.to_param
    assert_response :success
  end

  test "should update acl_entry" do
    put :update, :id => @acl_entry.to_param, :acl_entry => @acl_entry.attributes
    assert_redirected_to acl_entry_path(assigns(:acl_entry))
  end

  test "should destroy acl_entry" do
    assert_difference('AclEntry.count', -1) do
      delete :destroy, :id => @acl_entry.to_param
    end

    assert_redirected_to acl_entries_path
  end
end
