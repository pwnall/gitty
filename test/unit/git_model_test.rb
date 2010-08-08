require 'test_helper'

class GitModelTest < ActiveSupport::TestCase
  setup do
    @commit = commits(:commit1)
    @blob = blobs(:d1_d2_a)
    @tree = trees(:d1_d2)
  end
  
  test 'short_gitid' do
    assert_equal 'bf28647e', @commit.short_gitid, 'commit'
    assert_equal 'fb8247c7', @blob.short_gitid, 'blob'
    assert_equal 'c15e2d5a', @tree.short_gitid, 'tree'
  end
end
