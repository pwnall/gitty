require 'test_helper'

class TreesHelperTest < ActionView::TestCase
  setup do
    @branch = branches(:master)
    @commit = commits(:commit1)
    @gid = @commit.gitid
  end
  
  test 'tree_path with branch and path' do
    assert_equal '/dexter/ghost/tree/master/d1/d2',
                 tree_path(@branch, '/d1/d2')
  end

  test 'tree_path with commit and path' do
    assert_equal "/dexter/ghost/tree/#{@gid}/d1/d2",
                 tree_path(@commit, 'd1/d2')
  end

  test 'tree_path with commit' do
    assert_equal "/dexter/ghost/tree/#{@gid}",
                 tree_path(@commit)
  end

  test 'tree_path with branch' do
    assert_equal "/dexter/ghost/tree/master",
                 tree_path(@branch)
  end
end
