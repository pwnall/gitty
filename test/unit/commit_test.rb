require 'test_helper'

class CommitTest < ActiveSupport::TestCase
  def setup
    @repo = repositories(:dexter_ghost)
    @commit = Commit.new :gitid => 'becaeef98b57cfcc17472c001ebb5a4af5e4347b',
                         :author_name => 'Victor Costan',
                         :author_email => 'costan@gmail.com',
                         :committer_name => 'Victor Costan',
                         :committer_email => 'costan@gmail.com',
                         :authored_at => Time.now - 2,
                         :committed_at => Time.now - 1,
                         :repository => @repo
  end
  
  test 'setup' do
    assert @commit.valid?
  end
  
  test 'no duplicate git ids' do
    @commit.gitid = commits(:commit1).gitid
    assert !@commit.valid?
  end
  
  test 'repository must be set' do
    @commit.repository = nil
    assert !@commit.valid?
  end
  
  test 'from_git_commit' do
    mock_repository_path @repo
    git_commit = @repo.grit_repo.commit @commit.gitid
    
    git_tree = git_commit.tree
    tree = Tree.from_git_tree git_tree, @repo
    tree.save!
    
    commit = Commit.from_git_commit git_commit, @repo
    assert commit.valid?, 'Invalid commit created from git'
    assert_equal tree, commit.tree, 'Tree'
    assert_equal @commit.author_name, commit.author_name, 'Author name'
    assert_equal @commit.committer_name, commit.committer_name, 'Committer name'
    assert_equal @commit.author_email, commit.author_email, 'Author email'
    assert_equal @commit.committer_email, commit.committer_email,
                 'Committer email'
    commit.save!
    assert !@commit.valid?, "Commit incorrectly created from git"
  end
end
