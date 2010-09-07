require 'test_helper'

class TreeEntryTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @entry = TreeEntry.new :tree => trees(:commit1_root),
                           :child => blobs(:d1_b), :name => 'b'
  end
  
  test 'setup' do
    assert @entry.valid?
  end
  
  test 'no duplicate names' do
    @entry.name = 'd1'
    assert !@entry.valid?
  end
  
  test 'duplicate objects with different names are ok' do
    @entry.name = 'new'
    @entry.tree = trees(:commit2_d1)
    assert @entry.valid?
  end
  
  test 'tree must be set' do
    @entry.tree = nil
    assert !@entry.valid?
  end

  test 'child be set' do
    @entry.child = nil
    assert !@entry.valid?
  end

  test 'name be set' do
    @entry.name = nil
    assert !@entry.valid?
  end
  
  test 'from_git_tree' do
    mock_repository_path @repo
    TreeEntry.destroy_all

    git_tree = @repo.grit_repo.tree trees(:commit2_d1).gitid
    entries = TreeEntry.from_git_tree git_tree, @repo
    assert_equal [trees(:commit2_d1), trees(:commit2_d1)],
                 entries.map(&:tree), 'Tree'
    assert_equal Set.new([trees(:d1_d2), blobs(:d1_b)]),
                 Set.new(entries.map(&:child)), 'Children'
    assert_equal ['b', 'd2'], entries.map(&:name).sort, 'Names'
    assert entries.all?(&:valid?), 'Valid entries'
    entries.each(&:save!)  # Smoke-test saving.
  end
end
