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
                         :message => 'Commit 3',
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
  
  test 'committer_name must be set' do
    @commit.committer_name = nil
    assert !@commit.valid?
  end
  test 'committer_email must be set' do
    @commit.committer_email = nil
    assert !@commit.valid?
  end
  test 'author_name must be set' do
    @commit.author_name = nil
    assert !@commit.valid?
  end
  test 'author_email must be set' do
    @commit.author_email = nil
    assert !@commit.valid?
  end
  
  test 'message must be set' do
    @commit.message = nil
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
  
  test 'walk_path' do
    assert_equal trees(:d1_d2), commits(:commit1).walk_path('/d1/d2')
  end  
end
