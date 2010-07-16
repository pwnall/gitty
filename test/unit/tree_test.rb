require 'test_helper'

class TreeTest < ActiveSupport::TestCase
  def setup
    @repo = repositories(:dexter_ghost)
    @tree = Tree.new :gitid => 'c5411c50d6c35cb4c1d0c75e16db82bd3a12113d',
                     :repository => @repo
  end
  
  test 'setup' do
    assert @tree.valid?
  end
  
  test 'no duplicate git ids' do
    @tree.gitid = trees(:commit1_root).gitid
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
end
