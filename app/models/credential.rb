# Credential used to prove the identity of a user.
class Credential < ActiveRecord::Base
  include Authpwn::CredentialModel

  # Add your extensions to the Credential class here.
end

# namespace for all Credential subclasses
module Credentials

# Add your custom Credential types here.

end
