require 'test_helper'

class CommitsHelperTest < ActionView::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @branch = branches(:branch1)
    @commit = commits(:hello)
    @tag = tags(:v1)
  end

  test 'contextual_commits_path with full overspecified context' do
    assert_equal '/dexter/ghost/commits/branch1',
                 contextual_commits_path(@repo, @branch, @tag, @commit)
  end

  test 'contextual_commits_path with tag-led overspecified context' do
    assert_equal '/dexter/ghost/commits/v1.0',
                 contextual_commits_path(@repo, nil, @tag, @commit)
  end

  test 'contextual_commits_path with commit context' do
    assert_equal "/dexter/ghost/commits/master",
                 contextual_commits_path(@repo, nil, nil, @commit)
  end

  test 'contextual_commits_path with no context' do
    assert_equal '/dexter/ghost/commits/master',
                 contextual_commits_path(@repo, nil, nil, nil)
  end  
end
