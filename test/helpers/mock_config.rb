require 'etc'

class ActiveSupport::TestCase
  # Replace the git_user config var with the current user.
  #
  # This makes it easy to test paths, by comparing against
  # File.expand_path('~/some/path').
  #
  # The method should be used with great care, as it can cause varius methods
  #
  # to return paths that actually exist on the filesystem. Misuse can result
  # in loss of user data.
  def mock_git_user_with_current_user
    ConfigVar['git_user'] = Etc.getlogin
  end
end
