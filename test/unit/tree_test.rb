require 'test_helper'

class TreeTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @tree = Tree.new :gitid => 'a6ffe7f0b6d11b67df94795512c11460e303e2a2',
                     :repository => @repo
  end
  
  test 'setup' do
    assert @tree.valid?
  end
  
  test 'no duplicate git ids' do
    @tree.gitid = trees(:hello_root).gitid
    assert !@tree.valid?
  end
  
  test 'repository must be set' do
    @tree.repository = nil
    assert !@tree.valid?
  end
  
  test 'from_git_tree' do
    mock_repository_path @repo
    git_tree = @repo.grit_repo.tree(@tree.gitid)
    tree = Tree.from_git_tree git_tree, @repo
    assert tree.valid?, 'Invalid tree created from git'
    tree.save!
    assert !@tree.valid?, "Tree incorrectly created from git"
  end
  
  test 'walk_path' do
    tree = trees(:hello_root)
    assert_equal trees(:hello_lib), tree.walk_path('/lib')
    assert_equal trees(:lib_ghost), tree.walk_path('/lib/ghost')
    assert_equal blobs(:lib_ghost_hello_rb),
                 tree.walk_path('/lib/ghost/hello.rb')
    assert_equal nil, tree.walk_path('/lib/ghost/ghost.rb')
  end
end
