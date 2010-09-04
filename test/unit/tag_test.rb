require 'test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @tag = Tag.new :name => 'tag', :commit => commits(:commit1),
                   :committer_name => 'Victor Costan',
                   :committer_email => 'costan@gmail.com',
                   :committed_at => Time.now - 1,
                   :message => 'Tagged version tag.',
                   :repository => @repo
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
    
    git_commit3 =
       @repo.grit_repo.commit 'becaeef98b57cfcc17472c001ebb5a4af5e4347b'
    Tree.from_git_tree(git_commit3.tree, @repo).save!
    commit3 = Commit.from_git_commit git_commit3, @repo
    commit3.save!
    
    git_tag = @repo.grit_repo.tags.find { |t| t.name == 'demo' }
    tag = Tag.from_git_tag git_tag, @repo
    assert_equal commit3, tag.commit
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
