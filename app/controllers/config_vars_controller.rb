# Viewing and changing configuration variables.
class ConfigVarsController < ApplicationController
  config_vars_controller
  
  # Configuration variables are usually sensitive, so let's put some protection
  # around modifying them. At the very least, change the password here.
  USER, PASSWORD = 'config', 'vars'
  before_filter :http_basic_check
  def http_basic_check
    authenticate_or_request_with_http_basic do |user, password|
      user == USER && password == PASSWORD
    end
  end
  private :http_basic_check
end
