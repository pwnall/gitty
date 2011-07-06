# Wraps an OAuth2 access token for Facebook.
class FacebookToken < ActiveRecord::Base
  include AuthpwnRails::FacebookTokenModel

  # Add your extensions to the FacebookToken class here.  
end
