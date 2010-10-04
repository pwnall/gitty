require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  setup :mock_profile_paths

  setup do
    @repo = Repository.new :name => 'awesome', :profile => profiles(:dexter)
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
    ['$awesome', 'space name', 'quo"te', "more'quote", '-flag',
     'loose-', '.hidden', 'confused.'].each do |name|
      @repo.name = name
      assert !@repo.valid?
    end    
  end
  
  test 'valid names' do
    ['awesome', 'great-idea', 'great.idea', "CamelCased"].each do |name|
      @repo.name = name
      assert @repo.valid?
    end    
  end
  
  test 'profile_name' do
    assert_equal 'dexter', @repo.profile_name
  end
  
  test 'profile_name set to nil' do
    @repo.profile_name  # Uncover any caching issues.
    @repo.profile

    @repo.profile_name = nil
    assert_equal nil, @repo.profile_name, 'profile_name'
    assert_equal nil, @repo.profile, 'profile association'
  end
  
  test 'profile_name set' do
    @repo.profile_name  # Uncover any caching issues.
    @repo.profile

    @repo.profile_name = 'costan'
    assert_equal 'costan', @repo.profile_name
    assert_equal profiles(:costan), @repo.profile
  end
  
  test 'local_path' do
    mock_profile_paths_undo
    if RUBY_PLATFORM =~ /darwin/
      assert_equal '/Users/git-test/repos/dexter/awesome.git', @repo.local_path
    else
      assert_equal '/home/git-test/repos/dexter/awesome.git', @repo.local_path
    end
  end  
  
  test 'ssh_uri' do
    assert_equal 'git-test@localhost:dexter/awesome.git', @repo.ssh_uri
  end
  
  test 'ssh_path' do
    assert_equal 'dexter/awesome.git', @repo.ssh_path
  end

  test 'find_by_ssh_path' do
    assert_equal repositories(:dexter_ghost),
                 Repository.find_by_ssh_path('dexter/ghost.git')
    ['../something/else.git', 'dexter/ghost/more.git',
     'nobody/ghost.git', 'dexter/nothing.git'].each do |path|
      assert_equal nil, Repository.find_by_ssh_path(path), "Bad path #{path}"
    end
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
  
  test 'tag_changes with an empty db' do
    @repo.save!
    mock_repository_path @repo
    
    changes = @repo.tag_changes
    assert changes[:deleted].empty?, 'No tags were deleted'
    assert changes[:changed].empty?, 'No tags were changed'
    assert_equal ['demo', 'unicorns', 'v1.0', 'v2.0'],
                 changes[:added].map(&:name).sort, 'Added branches'
  end
  
  test 'tag_changes with fixtures' do
    repo = repositories(:dexter_ghost)
    mock_repository_path repo
    
    changes = repo.tag_changes
    assert_equal [tags(:ci_request)], changes[:deleted], 'Deleted tags'
    assert_equal [tags(:unicorns)], changes[:changed].keys,
                 'Changed tags keys'
    assert_equal ['unicorns'], changes[:changed].values.map(&:name),
                 'Changed tags values'
    assert_equal ['demo', 'v2.0'],
                 changes[:added].map(&:name).sort, 'Added tags'
  end

  test 'commits_added with an empty db' do
    @repo.save!
    mock_repository_path @repo
    commit_a = commits(:commit1).gitid
    commit_b1 = commits(:commit2).gitid
    commit_b2 = 'becaeef98b57cfcc17472c001ebb5a4af5e4347b'
    commit_c = '7ab1d7b5c5ddf87c73636109a9b256c23c3e0bed'
    
    branches = @repo.grit_repo.branches.index_by(&:name)
    tags = @repo.grit_repo.tags.index_by(&:name)
    
    commit_ids = @repo.commits_added([branches['master']]).map(&:id)
    assert_equal [commit_a, commit_b1, commit_b2, commit_c].sort,
                 commit_ids.sort, 'Added commits on master'
    [
      [commit_a, commit_b1], [commit_b1, commit_c], [commit_b2, commit_c]     
    ].each do |parent, child|
      assert_operator commit_ids.index(parent), :<, commit_ids.index(child),
                      'Topological sort failed'
    end

    # NOTE: branch test repeated for tag. to make sure tags are accepted as well
    commit_ids = @repo.commits_added([tags['v2.0']]).map(&:id)
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
  
  test 'contents_added with empty db' do
    @repo.save!
    mock_repository_path @repo
    
    commit_a = @repo.grit_repo.commit(commits(:commit1).gitid)
    commit_b1 = @repo.grit_repo.commit(commits(:commit2).gitid)
    
    bits = @repo.contents_added([commit_a, commit_a])
    assert_equal [blobs(:d1_d2_a).gitid], bits[:blobs].map(&:id),
                 'Blobs for commit 1'
    assert_equal [trees(:d1_d2), trees(:commit1_d1), trees(:commit1_root)].
                 map(&:gitid), bits[:trees].map(&:id), 'Trees for commit 1'    
  
    # NOTE: order dependent on topological sort implementation details, but not
    #       on Grit implementation

    bits = @repo.contents_added([commit_a, commit_b1])
    assert_equal [blobs(:d1_b), blobs(:d1_d2_a)].map(&:gitid),
                 bits[:blobs].map(&:id), 'Blobs for commit 2'
    assert_equal [trees(:d1_d2), trees(:commit2_d1), trees(:commit1_d1),
                  trees(:commit2_root), trees(:commit1_root)].map(&:gitid),
                 bits[:trees].map(&:id), 'Trees for commit 2'
  end
  
  test 'contents_added with fixtures' do
    repo = repositories(:dexter_ghost)
    mock_repository_path repo

    commit_a = repo.grit_repo.commit commits(:commit1).gitid
    commit_b1 = repo.grit_repo.commit commits(:commit2).gitid
    commit_b2 = repo.grit_repo.commit 'becaeef98b57cfcc17472c001ebb5a4af5e4347b'
    commit_c = repo.grit_repo.commit '7ab1d7b5c5ddf87c73636109a9b256c23c3e0bed'
    d1_b2 = '5146ab699d565600dc54251c226d6e528b448b93'
    commit3_root = 'c5411c50d6c35cb4c1d0c75e16db82bd3a12113d'
    commit3_d1 = '0583a12952e34e9e1e8387963f61bca56e7025ad'
    commit3_d1_d2 = 'd11a38de02c1bd03dd14ec0928748cc8aa86d6c2'
    commitm_root = 'd8949111e5d63fa7e82888efd340844cbaa1cc0e'
    commitm_d1 = '0c5e66ffb62b42f6ea7138cae8dff7e24a125c35'
    
    bits = repo.contents_added([commit_a, commit_b1])
    assert_equal [], bits[:blobs], 'No new blobs in commit 2'
    assert_equal [], bits[:trees], 'No new trees for commit 2'
    
    bits = repo.contents_added([commit_a, commit_b1, commit_b2])
    assert_equal [d1_b2], bits[:blobs].map(&:id), 'Blobs for commit 3'
    assert_equal [commit3_d1_d2, commit3_d1, commit3_root],
                 bits[:trees].map(&:id), 'Trees for commit 3'
    
    bits = repo.contents_added([commit_a, commit_b1, commit_c, commit_b2])
    assert_equal [d1_b2], bits[:blobs].map(&:id), 'Blobs for merge commit'
    assert_equal [commit3_d1_d2, commit3_d1, commitm_d1, commit3_root,
                  commitm_root],
                 bits[:trees].map(&:id), 'Trees for merge commit'
  end
  
  test 'integrate_changes' do
    repo = repositories(:dexter_ghost)
    mock_repository_path repo
    delta = nil
    assert_no_difference 'Branch.count' do
      assert_difference 'Tag.count', 1 do
        assert_difference 'Commit.count', 2 do
          assert_difference 'CommitParent.count', 3 do
            assert_difference 'TreeEntry.count', 9 do
              delta = repo.integrate_changes
            end
          end
        end
      end
    end
    
    assert_equal ['Commit 3', "Merge branch 'branch1'"],
                 delta[:commits].map(&:message).sort, 'New commits'
    assert_equal ['deleted'], delta[:branches][:deleted].map(&:name),
                 'Deleted branches'
    assert delta[:branches][:deleted].all?(&:destroyed?),
                 "Deleted branches weren't destroyed"
    assert_equal ['branch2'], delta[:branches][:added].map(&:name),
                 'Added branches'
    assert_equal ['master'], delta[:branches][:changed].map(&:name),
                 'Changed branches'
    assert_equal ['ci_request'], delta[:tags][:deleted].map(&:name),
                 'Deleted tags'
    assert delta[:branches][:deleted].all?(&:destroyed?),
                 "Deleted tags weren't destroyed"
    assert_equal ['demo', 'v2.0'], delta[:tags][:added].map(&:name).sort,
                 'Added tags'
    assert_equal ['unicorns'], delta[:tags][:changed].map(&:name),
                 'Changed tags'
  end
    
  test 'acl for new repository' do
    @repo.save!
    assert_equal :edit, AclEntry.get(@repo.profile, @repo)
    assert @repo.can_read?(users(:jane)), 'author'
    assert @repo.can_commit?(users(:jane)), 'author'
    assert @repo.can_edit?(users(:jane)), 'author'
    assert !@repo.can_read?(users(:john)), 'unrelated user'
    assert !@repo.can_commit?(users(:john)), 'unrelated user'
    assert !@repo.can_edit?(users(:john)), 'unrelated user'
  end

  test 'can_read?' do
    assert !@repo.can_read?(nil), 'no user'
    repo = repositories(:costan_ghost)
    assert repo.can_read?(users(:john))
    assert repo.can_read?(users(:jane))
  end
  
  test 'can_commit?' do
    assert !@repo.can_commit?(nil), 'no user'
    repo = repositories(:costan_ghost)
    assert repo.can_commit?(users(:john)) 
    assert repo.can_commit?(users(:jane))
  end
  
  test 'can_edit?' do
    assert !@repo.can_edit?(nil), 'no user'
    repo = repositories(:costan_ghost)
    assert repo.can_edit?(users(:john))
    assert !repo.can_edit?(users(:jane))
  end
  
  test 'default_branch' do
    assert_equal nil, @repo.default_branch
    assert_equal branches(:master), repositories(:dexter_ghost).default_branch    
  end
end
