# Viewing and changing configuration variables.
class ConfigVarsController < ApplicationController
  include ConfigvarsRails::Controller

  config_vars_auth
end
