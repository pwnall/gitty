require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase   
  # Override the local repository path so it's in a temp directory.
  def mock_repo_path
    return if Repository.respond_to?(:real_local_path)

    repo_root = Rails.root.join 'tmp', 'test_git_root'
    FileUtils.mkdir_p repo_root    

    Repository.class_eval do
      (class <<self; self; end).class_eval do
        alias_method :real_local_path, :local_path
        define_method :local_path do |profile_name, name|
          repo_root.join(profile_name, name + '.git').to_s
        end
      end
    end    
  end
  setup :mock_repo_path
  
  def setup
    @repo = Repository.new :name => 'awesome', :profile => profiles(:dexter)
  end  
  
  test 'setup' do
    assert @repo.valid?
  end
    
  test 'profile has to be assigned' do
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
  
  test 'original local_path' do
    assert_equal '/home/git-test/repos/dexter/awesome.git',
                 Repository.real_local_path('dexter', 'awesome')
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
    assert !File.exist?('tmp/test_git_root/dexter/awesome.git/objects'),
           'Old repository not deleted on rename'
    assert !@repo.grit_repo, 'The Grit repository object exists after deletion'
  end
end
