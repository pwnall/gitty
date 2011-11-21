# Credential used to prove the identity of a user.
class Credential < ActiveRecord::Base
  include Authpwn::CredentialModel

  # Add your extensions to the Credential class here.
end

# Load built-in credential types, such as Email and Password.
require 'authpwn_rails/credentials.rb'

# namespace for all Credential subclasses
module Credentials

# Add your custom Credential types here.
  
end
