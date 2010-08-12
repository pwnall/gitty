require 'test_helper'

class RepositoryPathsHelperTest < ActionView::TestCase
  setup do
    @branch = branches(:master)
    @commit = commits(:commit1)
    @gid = @commit.gitid
    @short_gid = @commit.short_gitid
  end
  
  test 'blob_path_links' do
    golden = %Q|<a href="/dexter/ghost">ghost</a> / <a href="/dexter/ghost/branch/master">master</a> / <a href="/dexter/ghost/tree/master/d1">d1</a> / <a href="/dexter/ghost/tree/master/d1/d2">d2</a> / <a href="/dexter/ghost/blob/master/d1/d2/a">a</a>|
    assert_equal golden, blob_path_links(@branch, 'd1/d2/a')
  end
  
  test 'tree_path_links' do
    golden = %Q|<a href="/dexter/ghost">ghost</a> / <a href="/dexter/ghost/commit/#{@gid}">#{@short_gid}</a> / <a href="/dexter/ghost/tree/#{@gid}/d1">d1</a> / <a href="/dexter/ghost/tree/#{@gid}/d1/d2">d2</a>|
    assert_equal golden, tree_path_links(@commit, 'd1/d2')
  end
  
  test 'tree_path_links with root tree' do
    golden = %Q|<a href="/dexter/ghost">ghost</a> / <a href="/dexter/ghost/branch/master">master</a> / |
    assert_equal golden, blob_path_links(@branch, '/')
  end
end
