require 'test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @tag = Tag.new name: 'tag', commit: commits(:hello),
                   committer_name: 'Dexter',
                   committer_email: 'dexter@gmail.com',
                   committed_at: Time.parse('Mon Apr 2 16:18:19 2012 -0400'),
                   message: 'Tagged version tag.',
                   repository: @repo
  end
  
  test 'setup' do
    assert @tag.valid?
  end
  
  test 'no duplicate names' do
    @tag.name = 'v1.0'
    assert !@tag.valid?
  end
    
  test 'commit must be set' do
    @tag.commit = nil
    assert !@tag.valid?
  end
  
  test 'committer_name must be set' do
    @tag.committer_name = nil
    assert !@tag.valid?
  end
  test 'committer_email must be set' do
    @tag.committer_email = nil
    assert !@tag.valid?
  end
  
  test 'message must be set' do
    @tag.message = nil
    assert !@tag.valid?
  end  

  test 'repository be set' do
    @tag.repository = nil
    assert !@tag.valid?
  end
  
  test 'from_git_branch' do
    mock_repository_path @repo
    
    git_easy_commit =
       @repo.grit_repo.commit '93d00ea479394cd110116b29748538d16d9b931e'
    Tree.from_git_tree(git_easy_commit.tree, @repo).save!
    easy_commit = Commit.from_git_commit git_easy_commit, @repo
    easy_commit.save!
    
    git_tag = @repo.grit_repo.tags.find { |t| t.name == 'demo' }
    tag = Tag.from_git_tag git_tag, @repo
    assert_equal easy_commit, tag.commit
    assert tag.new_record?, 'New record for tag'
    assert_equal @repo, tag.repository
    assert_equal 'demo', tag.name
    assert_equal @tag.committer_name, tag.committer_name
    assert_equal @tag.committer_email, tag.committer_email
    assert_equal 'Demo private build.', tag.message
    assert tag.valid?, 'Valid tag'
    tag.save!  # Smoke-test saving.
  end
end
