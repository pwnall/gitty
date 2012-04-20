require 'test_helper'

class GitObjectModelTest < ActiveSupport::TestCase
  setup do
    @commit = commits(:hello)
    @blob = blobs(:lib_ghost_hello_rb)
    @submodule = submodules(:markdpwn_012)
    @tree = trees(:lib_ghost)
  end
  
  test 'short_gitid' do
    assert_equal '09129da5a9d7b16d4f12', @commit.short_gitid, 'commit'
    assert_equal 'fe629487131256f4d47c', @blob.short_gitid, 'blob'
    assert_equal '50dd97ed5108082b0d0c', @submodule.short_gitid, 'submodule'
    assert_equal 'afd48debd11b5fe644ad', @tree.short_gitid, 'tree'
  end
end
