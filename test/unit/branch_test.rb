require 'test_helper'

class BranchTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @branch = Branch.new name: 'branch2', commit: commits(:hello),
                         repository: @repo
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
    
    git_easy_commit =
       @repo.grit_repo.commit '93d00ea479394cd110116b29748538d16d9b931e'
    Tree.from_git_tree(git_easy_commit.tree, @repo).save!
    easy_commit = Commit.from_git_commit git_easy_commit, @repo
    easy_commit.save!
    
    git_branch2 = @repo.grit_repo.branches.find { |b| b.name == 'branch2' }
    branch = Branch.from_git_branch git_branch2, @repo
    assert_equal easy_commit, branch.commit, 'Commit for branch2'
    assert branch.new_record?, 'New record for branch2'
    assert_equal @repo, branch.repository, 'Repository for branch2'
    assert_equal 'branch2', branch.name, 'Name for branch2'
    assert branch.valid?, 'Valid branch2'
    branch.save!  # Smoke-test saving.
    
    git_merge_commit =
       @repo.grit_repo.commit '88ca4433d478d6abb6558bebb9524fb72300457e'
    Tree.from_git_tree(git_merge_commit.tree, @repo).save!
    merge_commit = Commit.from_git_commit git_merge_commit, @repo
    merge_commit.save!

    git_branch_m = @repo.grit_repo.branches.find { |b| b.name == 'master' }
    branch = Branch.from_git_branch git_branch_m, @repo
    assert_equal merge_commit, branch.commit, 'Commit for master'
    assert !branch.new_record?, 'Existing master branch record used'
    assert_equal @repo, branch.repository, 'Repository for master'
    assert_equal 'master', branch.name, 'Name for master'
    assert branch.valid?, 'Valid master branch'
    branch.save!  # Smoke-test saving.
  end
end
