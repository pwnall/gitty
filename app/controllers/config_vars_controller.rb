# Viewing and changing configuration variables.
class ConfigVarsController < ApplicationController
  config_vars_controller
  
  # Configuration variables are usually sensitive, so let's put some protection
  # around modifying them.
  before_filter :http_basic_check
  def http_basic_check
    authenticate_or_request_with_http_basic(
        ConfigVar['config_vars.http_realm']) do |user, password|
      user == ConfigVar['config_vars.http_user'] &&
          password == ConfigVar['config_vars.http_password']
    end
  end
  private :http_basic_check
end
