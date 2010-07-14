require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  setup :mock_profile_paths
  
  def setup
    @profile = Profile.new :name => 'awesome',
                           :display_name => 'Awesome Profile'
  end  
  
  test 'local_path' do
    mock_profile_paths_undo
    
    assert_equal '/home/git-test/repos/awesome', @profile.local_path
  end
  
  test 'setup' do
    assert @profile.valid?
  end
  
  test 'name has to be unique' do
    @profile.name = profiles(:costan).name
    assert !@profile.valid?
  end
  
  test 'no funky names' do
    ['$awesome', 'space name', 'quo"te', "more'quote"].each do |name|
      @profile.name = name
      assert !@profile.valid?
    end
  end
    
  test 'display name has to be non-nil' do
    @profile.display_name = nil
    assert !@profile.valid?
  end
  
  test 'model-directory lifetime sync' do
    @profile.save!
    assert File.exist?('tmp/test_git_root/awesome'),
           'Profile directory not created on disk'
        
    @profile.update_attributes! :name => 'pwnage'
    assert !File.exist?('tmp/test_git_root/awesome'),
           'Old directory not deleted on rename'
    assert File.exist?('tmp/test_git_root/pwnage'),
           'New directory not created on rename'

    @profile.destroy
    assert !File.exist?('tmp/test_git_root/pwnage'),
           'Old directory not deleted on rename'
  end
end
