class ApplicationController < ActionController::Base
  protect_from_forgery
  authenticates_using_session
end
