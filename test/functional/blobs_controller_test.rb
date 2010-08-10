require 'test_helper'

class BlobsControllerTest < ActionController::TestCase
  setup do
    @blob = blobs(:one)
  end

  test "should show blob" do
    get :show, :id => @blob.to_param
    assert_response :success
  end
end
