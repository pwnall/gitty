require 'test_helper'

class CommitDiffHunksHelperTest < ActionView::TestCase
  test 'commit_patch_line_class' do
    assert_equal 'added', commit_patch_line_class([nil, 1, nil, 'New'])
    assert_equal 'deleted', commit_patch_line_class([1, nil, 'Dead', nil])
    assert_equal 'same', commit_patch_line_class([1, 1, 'Context', 'Context'])
  end
end
