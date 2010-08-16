require 'test_helper'

class UserHomeDirTest < ActiveSupport::TestCase
  setup do
    case RUBY_PLATFORM
    when /darwin/
      @prefix = '/Users/'
    else
      @prefix = '/home/'
    end
  end
  
  test 'for' do
    assert_equal "#{@prefix}git", UserHomeDir.for('git')
  end
end
