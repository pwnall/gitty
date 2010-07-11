require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase 
  def setup
    @repo = Repository.new :name => 'awesome'
  end
  
  # Override the local repository path so it's in a temp directory.
  def mock_repo_path
    return if Repository.respond_to?(:real_local_path)

    repo_root = Rails.root.join 'tmp', 'test_git_root'
    FileUtils.mkdir_p repo_root    

    Repository.class_eval do
      (class <<self; self; end).class_eval do
        alias_method :real_local_path, :local_path
        define_method :local_path do |name|
          repo_root.join(name + '.git').to_s
        end
      end
    end    
  end
  setup :mock_repo_path  
  
  test 'setup' do
    assert @repo.valid?
  end
    
  test 'name has to be unique' do
    @repo.name = repositories(:ghost).name
    assert !@repo.valid?
  end  
  
  test 'original local_path' do
    assert_equal '/home/git/awesome.git', Repository.real_local_path('awesome')
  end
  
  test 'model-repository lifetime sync' do
    @repo.save!
    assert File.exist?('tmp/test_git_root/awesome.git/objects'),
           'Repository not created on disk'
    assert @repo.grit_repo.branches, 
           'The Grit repository object is broken after creation'
        
    @repo.name = 'pwnage'
    @repo.save!
    assert !File.exist?('tmp/test_git_root/awesome.git/objects'),
           'Old repository not deleted on rename'
    assert File.exist?('tmp/test_git_root/pwnage.git/objects'),
           'New repository not created on rename'
    assert @repo.grit_repo.branches, 
           'The Grit repository object is broken after rename'

    @repo.destroy
    assert !File.exist?('tmp/test_git_root/awesome.git/objects'),
           'Old repository not deleted on rename'
    assert !@repo.grit_repo, 'The Grit repository object exists after deletion'
  end
end
