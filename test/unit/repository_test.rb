require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  setup :mock_profile_paths

  def setup
    @repo = Repository.new :name => 'awesome', :profile => profiles(:dexter)
  end
  
  def fixture_repo_path
    Rails.root.join('test', 'fixtures', 'repo.git').to_s
  end
  
  test 'setup' do
    assert @repo.valid?
  end
    
  test 'profile has to be set' do
    @repo.profile = nil
    assert !@repo.valid?
  end
    
  test 'name has to be unique' do
    @repo.name = repositories(:dexter_ghost).name
    assert !@repo.valid?
  end
  
  test 'no funky names' do
    ['$awesome', 'space name', 'quo"te', "more'quote"].each do |name|
      @repo.name = name
      assert !@repo.valid?
    end    
  end
  
  test 'local_path' do
    mock_profile_paths_undo
    assert_equal '/home/git-test/repos/dexter/awesome.git', @repo.local_path
  end  
  
  test 'ssh_uri' do
    assert_equal 'git-test@localhost:dexter/awesome.git', @repo.ssh_uri
  end
  
  test 'model-repository lifetime sync' do    
    @repo.save!
    assert File.exist?('tmp/test_git_root/dexter/awesome.git/objects'),
           'Repository not created on disk'
    assert @repo.grit_repo.branches, 
           'The Grit repository object is broken after creation'
        
    @repo.name = 'pwnage'
    @repo.save!
    assert !File.exist?('tmp/test_git_root/dexter/awesome.git/objects'),
           'Old repository not deleted on rename'
    assert File.exist?('tmp/test_git_root/dexter/pwnage.git/objects'),
           'New repository not created on rename'
    assert @repo.grit_repo.branches,
           'The Grit repository object is broken after rename'

    @repo.destroy
    assert !File.exist?('tmp/test_git_root/dexter/pwnage.git/objects'),
           'Old repository not deleted on rename'
    assert !@repo.grit_repo, 'The Grit repository object exists after deletion'
  end
  
  def mock_repository_path(repo)
    grit_repo = Grit::Repo.new fixture_repo_path
    flexmock(repo).should_receive(:grit_repo).and_return(grit_repo)
  end    
  
  test 'branch_changes with an empty db' do
    @repo.save!
    mock_repository_path @repo
    
    changes = @repo.branch_changes
    assert changes[:deleted].empty?, 'No branches were deleted'
    assert changes[:changed].empty?, 'No branches were changed'
    assert_equal ['branch1', 'branch2', 'master'],
                 changes[:added].map(&:name).sort, 'Added branches'
  end
  
  test 'branch_changes with fixtures' do
    repo = repositories(:dexter_ghost)
    mock_repository_path repo
    
    changes = repo.branch_changes
    assert_equal [branches(:deleted)], changes[:deleted], 'Deleted branches'
    assert_equal [branches(:master)], changes[:changed].keys,
                 'Changed branches keys'
    assert_equal ['master'], changes[:changed].values.map(&:name),
                 'Changed branches values'
    assert_equal ['branch2'],
                 changes[:added].map(&:name).sort, 'Added branches'
  end
  
  test 'commits_added with an empty db' do
    @repo.save!
    mock_repository_path @repo
    commit_a = commits(:commit1).gitid
    commit_b1 = commits(:commit2).gitid
    commit_b2 = 'becaeef98b57cfcc17472c001ebb5a4af5e4347b'
    commit_c = '7ab1d7b5c5ddf87c73636109a9b256c23c3e0bed'
    
    branches = @repo.grit_repo.branches.index_by(&:name)
    commit_ids = @repo.commits_added([branches['master']]).map(&:id)
    assert_equal [commit_a, commit_b1, commit_b2, commit_c].sort,
                 commit_ids.sort, 'Added commits on master'
    [
      [commit_a, commit_b1], [commit_b1, commit_c], [commit_b2, commit_c]     
    ].each do |parent, child|
      assert_operator commit_ids.index(parent), :<, commit_ids.index(child),
                      'Topological sort failed'
    end
    
    branch1 = @repo.grit_repo.branches.find { |b| b.name == 'branch1' }
    commit_ids = @repo.commits_added([branches['branch1']]).map(&:id)
    assert_equal [commit_a, commit_b1], commit_ids, 'Added commits on branch1'

    branch2 = @repo.grit_repo.branches.find { |b| b.name == 'branch2' }
    commit_ids = @repo.commits_added([branches['branch2']]).map(&:id)
    assert_equal [commit_a, commit_b2], commit_ids, 'Added commits on branch2'
  
    # NOTE: branch orders here are dependent on an implementation detail, which
    #       is that branches are processed in turn; the test is robust against
    #       Grit changes, but possibly not against DFS implementation changes
    
    commit_ids = @repo.commits_added([branches['branch1'],
                                      branches['branch2']]).map(&:id)
    assert_equal [commit_a, commit_b1, commit_b2], commit_ids,
                 'Added commits on branch1 and branch2'

    commit_ids = @repo.commits_added([branches['branch1'], branches['master'],
                                      branches['branch2']]).map(&:id)
    assert_equal [commit_a, commit_b1, commit_b2, commit_c], commit_ids,
                 'Added commits on all branches'
  end

  test 'commits_added with fixtures' do
    repo = repositories(:dexter_ghost)
    mock_repository_path repo
    
    commit_b2 = 'becaeef98b57cfcc17472c001ebb5a4af5e4347b'
    commit_c = '7ab1d7b5c5ddf87c73636109a9b256c23c3e0bed'
    
    branches = repo.grit_repo.branches.index_by(&:name)
    commit_ids = repo.commits_added([branches['master']]).map(&:id)
    assert_equal [commit_b2, commit_c], commit_ids, 'Added commits on master'
    
    branch1 = repo.grit_repo.branches.find { |b| b.name == 'branch1' }
    commit_ids = repo.commits_added([branches['branch1']]).map(&:id)
    assert_equal [], commit_ids, 'Added commits on branch1'

    branch2 = repo.grit_repo.branches.find { |b| b.name == 'branch2' }
    commit_ids = repo.commits_added([branches['branch2']]).map(&:id)
    assert_equal [commit_b2], commit_ids, 'Added commits on branch2'
  
    commit_ids = repo.commits_added([branches['branch1'], branches['master'],
                                     branches['branch2']]).map(&:id)
    assert_equal [commit_b2, commit_c], commit_ids,
                 'Added commits on all branches'
  end
end
