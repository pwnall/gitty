require 'test_helper'

class CommitParentTest < ActiveSupport::TestCase
  def setup
    @repo = repositories(:dexter_ghost)
    @parent = CommitParent.new :commit => commits(:commit1),
                               :parent => commits(:commit2)
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
    
    git_commit3 =
       @repo.grit_repo.commit 'becaeef98b57cfcc17472c001ebb5a4af5e4347b'
    Tree.from_git_tree(git_commit3.tree, @repo).save!
    commit3 = Commit.from_git_commit git_commit3, @repo
    commit3.save!
    
    git_commit_m =
       @repo.grit_repo.commit '7ab1d7b5c5ddf87c73636109a9b256c23c3e0bed'
    Tree.from_git_tree(git_commit_m.tree, @repo).save!
    commit_m = Commit.from_git_commit git_commit_m, @repo
    commit_m.save!

    parents = CommitParent.from_git_commit git_commit_m, @repo
    assert_equal [commit_m, commit_m], parents.map(&:commit), 'Commit'
    assert_equal Set.new([commits(:commit2), commit3]),
                 Set.new(parents.map(&:parent)),
                 'Parents'
    assert parents.all?(&:valid?), 'Valid' 
    parents.each(&:save!)  # Smoke-test saving.
  end
end
