require 'test_helper'

class CommitDiffTest < ActiveSupport::TestCase
  setup do
    @diff = CommitDiff.new :commit => commits(:hello), 
        :old_path => '/lib/ghost/hello.rb', :new_path => '/lib/ghost.rb',
        :old_object => blobs(:lib_ghost_hello_rb),
        :new_object => blobs(:lib_ghost_rb)
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
    @diff.old_object = nil
    assert !@diff.valid?
    
    @diff.old_path = nil
    @diff.save!
    assert @diff.valid?
  end
    
  test 'new_object can be nil iff new_path is nil' do
    @diff.new_object = nil
    assert !@diff.valid?

    @diff.new_path = nil
    assert @diff.valid?
  end

  test 'old_path must be unique within a commit' do
    diff = @diff.commit.diffs.first
    diff.update_attributes! :old_path => @diff.old_path,
                            :old_object => @diff.old_object
    assert !@diff.valid?
  end
  
  test 'new_path must be unique within a commit' do
    @diff.new_path = @diff.commit.diffs.first.new_path
    assert !@diff.valid?
  end
  
  test 'new_path can match old_path' do
    @diff.new_path = @diff.old_path
  end
  
  test 'resolve_object' do
    mock_repository_path @repo
    git_repo = @repo.grit_repo
    git_commit = git_repo.commit(commits(:require).gitid)
  
    assert_equal nil, CommitDiff.resolve_object(nil, 'lib/ghost/hello.rb',
                                                @diff.commit)
    assert_equal blobs(:lib_ghost_hello_rb), CommitDiff.resolve_object(
        Grit::Blob.create(git_repo, :id => blobs(:lib_ghost_hello_rb).gitid,
                                    :size => blobs(:lib_ghost_hello_rb).size),
        'lib/ghost/hello.rb', @diff.commit)
    assert_equal submodules(:markdpwn_012), CommitDiff.resolve_object(
        Grit::Blob.create(git_repo, :id => submodules(:markdpwn_012).gitid,
                                    :size => 0),
        'lib/markdpwn', @diff.commit)
  end
  
  test 'from_git_commit with invalid commit' do
    mock_repository_path @repo
    git_commit = @repo.grit_repo.commit(commits(:require).gitid)
    assert_raise ArgumentError do
      CommitDiff.from_git_commit git_commit, commits(:hello)
    end
  end
  
  test 'from_git_commit' do
    mock_any_repository_path
    commit = @diff.commit
    g_commit = @repo.grit_repo.commit(commit.gitid)
    diffs = CommitDiff.from_git_commit g_commit, commit
    
    assert_equal 3, diffs.length, '3 diff'
    
    # Add .gitmodules
    diff = diffs.keys[0]
    assert_equal commit, diff.commit
    assert_nil diff.old_path, 'old_path'
    assert_nil diff.old_object, 'old_object'
    assert_equal '.gitmodules', diff.new_path
    assert_equal blobs(:gitmodules), diff.new_object
    assert_equal 1, diffs[diff].length, '1 diff hunk'
    assert_operator diffs[diff].first, :kind_of?, CommitDiffHunk

    # Add lib/ghost/hello.rb
    diff = diffs.keys[1]
    assert_equal commit, diff.commit
    assert_nil diff.old_path, 'old_path'
    assert_nil diff.old_object, 'old_object'
    assert_equal 'lib/ghost/hello.rb', diff.new_path
    assert_equal blobs(:lib_ghost_hello_rb), diff.new_object
    assert_equal 1, diffs[diff].length, '1 diff hunk'
    assert_operator diffs[diff].first, :kind_of?, CommitDiffHunk

    # Add lib/markdpwn submodule
    diff = diffs.keys[2]
    assert_equal commit, diff.commit
    assert_nil diff.old_path, 'old_path'
    assert_nil diff.old_object, 'old_object'
    assert_equal 'lib/markdpwn', diff.new_path
    assert_equal submodules(:markdpwn_012), diff.new_object, 'new_object'
    assert_equal 1, diffs[diff].length, '1 diff hunk'
    
    # Smoke test to ensure the diff is really valid.
    commit.diffs.destroy_all
    assert commit.valid?
    commit.save!
  end
end
