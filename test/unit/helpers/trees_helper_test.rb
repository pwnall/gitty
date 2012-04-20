require 'test_helper'

class TreesHelperTest < ActionView::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @branch = branches(:branch1)
    @commit = commits(:hello)
    @tag = tags(:v1)
    @gid = @commit.gitid
  end
  
  test 'tree_path with branch and path' do
    assert_equal '/dexter/ghost/tree/branch1/lib/ghost',
                 tree_path(@branch, '/lib/ghost')
  end

  test 'tree_path with tag and path' do
    assert_equal '/dexter/ghost/tree/v1.0/lib/ghost',
                 tree_path(@tag, '/lib/ghost')
  end

  test 'tree_path with commit and path' do
    assert_equal "/dexter/ghost/tree/#{@gid}/lib/ghost",
                 tree_path(@commit, 'lib/ghost')
  end

  test 'tree_path with branch' do
    assert_equal "/dexter/ghost/tree/branch1",
                 tree_path(@branch)
  end

  test 'tree_path with tag' do
    assert_equal '/dexter/ghost/tree/v1.0',
                 tree_path(@tag)
  end

  test 'tree_path with commit' do
    assert_equal "/dexter/ghost/tree/#{@gid}",
                 tree_path(@commit)
  end
  
  test 'contextual_tree_path with full overspecified context' do
    assert_equal '/dexter/ghost/tree/branch1',
                 contextual_tree_path(@repo, @branch, @tag, @commit)
  end

  test 'contextual_tree_path with tag-led overspecified context' do
    assert_equal '/dexter/ghost/tree/v1.0',
                 contextual_tree_path(@repo, nil, @tag, @commit)
  end

  test 'contextual_tree_path with commit context' do
    assert_equal "/dexter/ghost/tree/#{@gid}",
                 contextual_tree_path(@repo, nil, nil, @commit)
  end

  test 'contextual_tree_path with no context' do
    assert_equal '/dexter/ghost/tree/master',
                 contextual_tree_path(@repo, nil, nil, nil)
  end
end
