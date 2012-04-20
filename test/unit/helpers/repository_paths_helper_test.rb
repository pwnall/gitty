require 'test_helper'

class RepositoryPathsHelperTest < ActionView::TestCase
  setup do
    @branch = branches(:master)
    @commit = commits(:hello)
    @gid = @commit.gitid
    @short_gid = @commit.short_gitid
  end
  
  test 'blob_path_links' do
    golden = %Q|<a href="/dexter/ghost">ghost</a> / <a href="/dexter/ghost/branch/master">master</a> / <a href="/dexter/ghost/tree/master/lib">lib</a> / <a href="/dexter/ghost/tree/master/lib/ghost">ghost</a> / <a href="/dexter/ghost/blob/master/lib/ghost/hello.rb">hello.rb</a>|
    assert_equal golden, blob_path_links(@branch, 'lib/ghost/hello.rb')
  end
  
  test 'tree_path_links' do
    golden = %Q|<a href="/dexter/ghost">ghost</a> / <a href="/dexter/ghost/commit/#{@gid}">#{@short_gid}</a> / <a href="/dexter/ghost/tree/#{@gid}/lib">lib</a> / <a href="/dexter/ghost/tree/#{@gid}/lib/ghost">ghost</a>|
    assert_equal golden, tree_path_links(@commit, 'lib/ghost')
  end
  
  test 'tree_path_links with root tree' do
    golden = %Q|<a href="/dexter/ghost">ghost</a> / <a href="/dexter/ghost/branch/master">master</a> / |
    assert_equal golden, blob_path_links(@branch, '/')
  end
end
