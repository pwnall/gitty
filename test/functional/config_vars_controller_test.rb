require 'test_helper'

class ConfigVarsControllerTest < ActionController::TestCase
  setup do
    @config_var = config_vars(:app_uri)
  end
  
  test "cannot access config vars without authentication" do
    get :index
    assert_response :unauthorized    
  end
end
