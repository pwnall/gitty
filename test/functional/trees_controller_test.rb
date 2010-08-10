require 'test_helper'

class TreesControllerTest < ActionController::TestCase
  setup do
    @tree = trees(:one)
  end

  test "should show tree" do
    get :show, :id => @tree.to_param
    assert_response :success
  end
end
