require 'test_helper'

class CommitDiffTest < ActiveSupport::TestCase
  setup do
    @diff = CommitDiff.new :commit => commits(:commit1), 
        :old_path => '/d1/d2/a', :new_path => '/d1/b',
        :old_blob => blobs(:d1_d2_a), :new_blob => blobs(:d1_b)
    @repo = @diff.commit.repository
  end
  
  test 'setup' do
    assert @diff.valid?
  end
  
  test 'commit must be set' do
    @diff.commit = nil
    assert !@diff.valid?
  end
  
  test 'old_blob can be nil iff old_path is nil' do
    @diff.old_blob = nil
    assert !@diff.valid?
    
    @diff.old_path = nil
    @diff.save!
    assert @diff.valid?
  end
    
  test 'new_blob can be nil iff new_path is nil' do
    @diff.new_blob = nil
    assert !@diff.valid?

    @diff.new_path = nil
    assert @diff.valid?
  end

  test 'old_path must be unique within a commit' do
    diff = @diff.commit.diffs.first
    diff.update_attributes! :old_path => @diff.old_path,
                            :old_blob => @diff.old_blob
    assert !@diff.valid?
  end
  
  test 'new_path must be unique within a commit' do
    @diff.new_path = @diff.commit.diffs.first.new_path
    assert !@diff.valid?
  end
  
  test 'new_path can match old_path' do
    @diff.new_path = @diff.old_path
  end
  
  test 'from_git_commit with invalid commit' do
    mock_repository_path @repo
    g_commit = @repo.grit_repo.commit(commits(:commit2).gitid)
    assert_raise ArgumentError do
      CommitDiff.from_git_commit g_commit, commits(:commit1)
    end
  end
  
  test 'from_git_commit' do
    mock_any_repository_path
    commit = @diff.commit
    g_commit = @repo.grit_repo.commit(commit.gitid)
    diffs = CommitDiff.from_git_commit g_commit, commit
    
    assert_equal 1, diffs.length, '1 diff'
    diff = diffs.keys.first
    assert_equal commit, diff.commit
    assert_nil diff.old_path, 'old_path'
    assert_nil diff.old_blob, 'old_blob'
    assert_equal 'd1/d2/a', diff.new_path
    assert_equal blobs(:d1_d2_a), diff.new_blob
    assert_equal 1, diffs[diff].length, '1 diff hunk'
    assert_operator diffs[diff].first, :kind_of?, CommitDiffHunk
    
    # Smoke test to ensure the diff is really valid.
    commit.diffs.destroy_all
    assert commit.valid?
    commit.save!
  end
end
