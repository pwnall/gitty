require 'test_helper'

class BranchTest < ActiveSupport::TestCase
  def setup
    @repo = repositories(:dexter_ghost)
    @branch = Branch.new :name => 'branch2', :commit => commits(:commit1),
                         :repository => @repo
  end
  
  test 'setup' do
    assert @branch.valid?
  end
  
  test 'no duplicate names' do
    @branch.name = 'master'
    assert !@branch.valid?
  end
    
  test 'commit must be set' do
    @branch.commit = nil
    assert !@branch.valid?
  end

  test 'repository be set' do
    @branch.repository = nil
    assert !@branch.valid?
  end
  
  test 'from_git_branch' do
    mock_repository_path @repo
    
    git_commit3 =
       @repo.grit_repo.commit 'becaeef98b57cfcc17472c001ebb5a4af5e4347b'
    Tree.from_git_tree(git_commit3.tree, @repo).save!
    commit3 = Commit.from_git_commit git_commit3, @repo
    commit3.save!
    
    git_branch2 = @repo.grit_repo.branches.find { |b| b.name == 'branch2' }
    branch = Branch.from_git_branch git_branch2, @repo
    assert_equal commit3, branch.commit, 'Commit for branch2'
    assert branch.new_record?, 'New record for branch2'
    assert_equal @repo, branch.repository, 'Repository for branch2'
    assert_equal 'branch2', branch.name, 'Name for branch2'
    assert branch.valid?, 'Valid branch2'
    branch.save!  # Smoke-test saving.
    
    git_commit_m =
       @repo.grit_repo.commit '7ab1d7b5c5ddf87c73636109a9b256c23c3e0bed'
    Tree.from_git_tree(git_commit_m.tree, @repo).save!
    commit_m = Commit.from_git_commit git_commit_m, @repo
    commit_m.save!

    git_branch_m = @repo.grit_repo.branches.find { |b| b.name == 'master' }
    branch = Branch.from_git_branch git_branch_m, @repo
    assert_equal commit_m, branch.commit, 'Commit for master'
    assert !branch.new_record?, 'Existing master branch record used'
    assert_equal @repo, branch.repository, 'Repository for master'
    assert_equal 'master', branch.name, 'Name for master'
    assert branch.valid?, 'Valid master branch'
    branch.save!  # Smoke-test saving.
  end
end
