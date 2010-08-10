require 'test_helper'

class GitObjectModelTest < ActiveSupport::TestCase
  setup do
    @commit = commits(:commit1)
    @blob = blobs(:d1_d2_a)
    @tree = trees(:d1_d2)
  end
  
  test 'short_gitid' do
    assert_equal 'bf28647e6740e2970b8e', @commit.short_gitid, 'commit'
    assert_equal 'fb8247c7b27ae4cad9e7', @blob.short_gitid, 'blob'
    assert_equal 'c15e2d5a841838292a87', @tree.short_gitid, 'tree'
  end
end
