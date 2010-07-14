require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  setup :mock_profile_paths

  def setup
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
end
