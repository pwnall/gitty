require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  setup :mock_profile_paths
  
  setup do
    @profile = Profile.new :name => 'awesome',
                           :display_name => 'Awesome Profile'
  end  
  
  test 'local_path' do
    mock_profile_paths_undo
    
    if RUBY_PLATFORM =~ /darwin/
      assert_equal '/Users/git-test/repos/awesome', @profile.local_path
    else
      assert_equal '/home/git-test/repos/awesome', @profile.local_path
    end
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
  
  test 'can_participate' do
    profile = profiles(:csail)
    assert !profile.can_participate?(nil), 'no user'
    assert profile.can_participate?(users(:john)), 'participating user'
    assert !profile.can_participate?(users(:jane)), 'unrelated user'  
  end
  
  test 'can_charge?' do
    profile = profiles(:costan)
    assert !profile.can_charge?(nil), 'no user'
    assert profile.can_charge?(users(:john)), 'owning user'
    assert !profile.can_charge?(users(:jane)), 'unrelated user'
  end
  
  test 'can_edit?' do
    profile = profiles(:costan)
    assert !profile.can_edit?(nil), 'no user'
    assert profile.can_edit?(users(:john)), 'owning user'
    assert !profile.can_edit?(users(:jane)), 'unrelated user'
  end
  
  test 'acl_roles' do
    roles = Profile.acl_roles
    assert roles.length >= 0, 'There should be at least one ACL role'
    
    roles.each do |role|
      assert_equal 2, role.length, 'Role should have description and name'
      assert_operator role.first, :kind_of?, String,
          'Role should start with description'
      assert_operator role.last, :kind_of?, Symbol,
          'Role should end with name'
    end
    
    assert roles.any? { |role| role.last == :charge },
           'No charging role on a profile'
  end
  
  test 'acl_principal_class' do
    assert_equal Profile.acl_principal_class,
                 profiles(:dexter).acl_entries.first.principal.class
  end
  
  test 'team_profile?' do
    assert !profiles(:costan).team_profile?
    assert profiles(:csail).team_profile?
  end
  
  test 'members' do
    profile = profiles(:csail)
    assert_equal [users(:john), users(:sam)].to_set, profile.members.to_set
  end
  
  test 'recent_subscribed_feed_items' do
    profile = profiles(:dexter)
    items = [:dexter_unfollows_mit, :dexter_follows_mit, :dexter_creates_branch,
        :dexter_creates_ghost].map { |name| feed_items(name) }
    assert_equal items, profile.recent_subscribed_feed_items
    assert_equal [feed_items(:dexter_unfollows_mit)],
                 profile.recent_subscribed_feed_items(1)
  end
  
  test 'publish_subscribe to profile' do
    profile = profiles(:dexter)
    target = profiles(:csail)
    item = nil
    assert_difference 'FeedItem.count' do
      item = profile.publish_subscription target, true
    end
    assert_equal profile, item.author
    assert_equal 'subscribe', item.verb
    assert_equal target, item.target
    assert_equal 'csail', item.data[:profile_name]
  end
  
  test 'publish_unsubscribe from repository' do
    profile = profiles(:csail)
    target = repositories(:dexter_ghost)
    item = nil
    assert_difference 'FeedItem.count' do
      item = profile.publish_subscription target, false
    end
    assert_equal profile, item.author
    assert_equal 'unsubscribe', item.verb
    assert_equal target, item.target
    assert_equal 'dexter', item.data[:profile_name]
    assert_equal 'ghost', item.data[:repository_name]
  end
end
