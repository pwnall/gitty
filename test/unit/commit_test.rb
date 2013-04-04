require 'test_helper'

class CommitTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @commit = Commit.new gitid: '93d00ea479394cd110116b29748538d16d9b931e',
        author_name: 'Victor Costan',
        author_email: 'victor@costan.us',
        committer_name: 'Dexter',
        committer_email: 'dexter@gmail.com',
        authored_at: Time.parse('2012-04-02 16:17:18 -0400'),
        committed_at: Time.parse('2012-04-02 16:17:19 -0400'),
        message: 'Easy mode',
        repository: @repo
  end

  test 'setup' do
    assert @commit.valid?
  end

  test 'no duplicate git ids' do
    @commit.gitid = commits(:hello).gitid
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
    assert_equal @commit.authored_at, commit.authored_at, 'Date authored'
    assert_equal @commit.committed_at, commit.committed_at, 'Date committed'
    commit.save!
    assert !@commit.valid?, "Commit incorrectly created from git"
  end

  test 'walk_parents' do
    c1 = Commit.new committed_at: Time.now - 10, gitid: 'c1'
    c2 = Commit.new committed_at: Time.now - 9, gitid: 'c2',
                    parents: [c1]
    c3 = Commit.new committed_at: Time.now - 8, gitid: 'c3'
    c4 = Commit.new committed_at: Time.now - 7, gitid: 'c4',
                    parents: [c2, c3]
    c5 = Commit.new committed_at: Time.now - 6, gitid: 'c5',
                    parents: [c3, c4]

    assert_equal [c5, c4, c3, c2, c1], c5.walk_parents(0, 10)
    assert_equal [c5, c4, c3], c5.walk_parents(0, 3)
    assert_equal [c4, c3, c2, c1], c5.walk_parents(1, 4)
    assert_equal [c2, c1], c5.walk_parents(3, 5)
  end

  test 'walk_path' do
    assert_equal trees(:lib_ghost), commits(:hello).walk_path('/lib/ghost')
  end
end
