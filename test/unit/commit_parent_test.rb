require 'test_helper'

class CommitParentTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @parent = CommitParent.new :commit => commits(:hello),
                               :parent => commits(:require)
  end
  
  test 'setup' do
    assert @parent.valid?
  end
  
  test 'no duplicate relationships' do
    @parent.commit, @parent.parent = @parent.parent, @parent.commit
    assert !@parent.valid?
  end
  
  test 'commit must be set' do
    @parent.commit = nil
    assert !@parent.valid?
  end

  test 'parent must be set' do
    @parent.parent = nil
    assert !@parent.valid?
  end
  
  test 'from_git_commit' do
    mock_repository_path @repo
    
    git_easy_commit =
       @repo.grit_repo.commit '93d00ea479394cd110116b29748538d16d9b931e'
    Tree.from_git_tree(git_easy_commit.tree, @repo).save!
    easy_commit = Commit.from_git_commit git_easy_commit, @repo
    easy_commit.save!
    
    git_merge_commit =
       @repo.grit_repo.commit '88ca4433d478d6abb6558bebb9524fb72300457e'
    Tree.from_git_tree(git_merge_commit.tree, @repo).save!
    merge_commit = Commit.from_git_commit git_merge_commit, @repo
    merge_commit.save!

    parents = CommitParent.from_git_commit git_merge_commit, @repo
    assert_equal [merge_commit, merge_commit], parents.map(&:commit), 'Commit'
    assert_equal Set.new([commits(:require), easy_commit]),
                 Set.new(parents.map(&:parent)),
                 'Parents'
    assert parents.all?(&:valid?), 'Valid' 
    parents.each(&:save!)  # Smoke-test saving.
  end
end
