require 'test_helper'

class CommitDiffHunkTest < ActiveSupport::TestCase
  setup do
    @hunk = CommitDiffHunk.new :diff => commit_diffs(:commit1_d1_d2_a),
        :old_start => 1, :old_count => 5, :new_start => 3, :new_count => 6,
        :patch_text => <<END_PATCH
 First base line.
 Second base line.
-Dead line 1.
-Dead line 2.
+Added line 1.
+Added line 2.
+Added line 3.
 Third base line.
END_PATCH
    @repo = @hunk.diff.commit.repository
  end
  
  test 'setup' do
    assert @hunk.valid?
  end
  
  test 'diff must be present' do
    @hunk.diff = nil
    assert !@hunk.valid?
  end

  test 'old_start must be present and non-negative' do
    @hunk.old_start = nil
    assert !@hunk.valid?

    @hunk.old_start = -1
    assert !@hunk.valid?
  end

  test 'new_start must be present and non-negative' do
    @hunk.new_start = nil
    assert !@hunk.valid?

    @hunk.new_start = -1
    assert !@hunk.valid?
  end

  test 'old_count must be present and non-negative' do
    @hunk.old_count = nil
    assert !@hunk.valid?

    @hunk.old_start = -1
    assert !@hunk.valid?
  end

  test 'new_count must be present and non-negative' do
    @hunk.new_start = nil
    assert !@hunk.valid?

    @hunk.new_count = -1
    assert !@hunk.valid?
  end
  
  test '(old_start, new_start) must be unique for a commit' do
    hunk = @hunk.diff.hunks.first
    @hunk.old_start, @hunk.new_start = hunk.old_start, hunk.new_start
    assert !@hunk.valid?
  end
  
  test 'patch_lines' do
    lines = @hunk.patch_lines
    
    assert_equal (1..5).to_a, lines.map { |l| l[0] }.select { |l| l},
                 'old lines are monotonic'
    assert_equal (3..8).to_a, lines.map { |l| l[1] }.select { |l| l},
                 'new lines are monotonic'
  
    lines.each do |line|
      assert_equal line[0].nil?, line[2].nil?,
                   'old line number and contents are consistent'
      assert_equal line[1].nil?, line[3].nil?,
                   'new line number and contents are consistent'
    end
    
    assert_equal [4, nil, 'Dead line 2.', nil], lines[3]
    assert_equal [nil, 6, nil, 'Added line 2.'], lines[5]
    assert_equal [5, 8, 'Third base line.', 'Third base line.'], lines[7]
  end
  
  test 'from_git_diff' do
    mock_any_repository_path
    diff = @hunk.diff
    commit = diff.commit
    g_commit = @repo.grit_repo.commit(commit.gitid)

    
    hunks = CommitDiffHunk.from_git_diff(g_commit.diffs.first, diff)

    assert_equal 1, hunks.length, '1 hunk'
    assert_equal diff, hunks[0].diff
    assert_equal 0, hunks[0].old_start, 'old_start'
    assert_equal 0, hunks[0].old_count, 'old_count'
    assert_equal 1, hunks[0].new_start, 'new_start'
    assert_equal 1, hunks[0].new_count, 'new_count'
    assert_equal "+Version 1", hunks[0].patch_text
    
    # Smoke test to ensure the hunk is really valid.
    diff.hunks.destroy_all
    assert commit.valid?
    commit.save!
  end  
end
