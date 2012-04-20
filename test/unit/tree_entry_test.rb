require 'test_helper'

class TreeEntryTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @entry = TreeEntry.new :tree => trees(:hello_root),
                           :child => blobs(:lib_ghost_rb), :name => 'ghost.rb'
  end
  
  test 'setup' do
    assert @entry.valid?
  end
  
  test 'no duplicate names' do
    @entry.name = 'lib'
    assert !@entry.valid?
  end
  
  test 'duplicate objects with different names are ok' do
    @entry.name = 'new'
    @entry.tree = trees(:require_lib)
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

    git_tree = @repo.grit_repo.tree trees(:require_lib).gitid
    entries = TreeEntry.from_git_tree git_tree, @repo
    assert_equal [trees(:require_lib), trees(:require_lib),
                  trees(:require_lib)], entries.map(&:tree), 'Tree'
    assert_equal Set.new([trees(:lib_ghost), blobs(:lib_ghost_rb),
                          submodules(:markdpwn_012)]),
                 Set.new(entries.map(&:child)), 'Children'
    assert_equal ['ghost', 'ghost.rb', 'markdpwn'],
                 entries.map(&:name).sort, 'Names'
    assert entries.all?(&:valid?), 'Valid entries'
    entries.each(&:save!)  # Smoke-test saving.
  end
end
