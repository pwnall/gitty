require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.new :email => 'someone@gmail.com', :password => 'awesome',
                     :password_confirmation => 'awesome'
  end
  
  test 'setup' do
    assert @user.valid?
  end
  
  test 'name' do
    assert_equal 'costan@gmail.com', users(:costan).name
  end
  
  test 'admin set to false by default' do
    assert_equal false, @user.admin?
  end

  test 'admin=true is valid' do
    @user.admin = true
    assert @user.valid?
  end
  
  test 'admin cannot be nil' do
    @user.admin = nil
    assert !@user.valid?
  end
  
  test 'can_read?' do
    assert users(:costan).can_read?(users(:costan)), 'same user'
    assert !users(:costan).can_read?(users(:dexter)), 'different users'
    assert !users(:costan).can_read?(nil), 'no user signed in'
  end

  test 'can_edit?' do
    assert users(:costan).can_edit?(users(:costan)), 'same user'
    assert !users(:costan).can_edit?(users(:dexter)), 'different users'
    assert !users(:costan).can_edit?(nil), 'no user signed in'
  end

  test 'can_list_users?' do
    users(:dexter).admin = true
    assert User.can_list_users?(users(:dexter)), 'admin'
    assert !User.can_list_users?(users(:costan)), 'non-admin'
    assert !User.can_list_users?(users(:costan)), 'no user signed in'
  end
  
  test 'find_by_name' do
    assert_equal users(:costan), User.find_by_name(users(:costan).name), 'by email'
    assert_equal users(:costan), User.find_by_name(users(:costan).profile.name),
                 'by profile name'
    assert_equal nil, User.find_by_name('random@user.com'), 'invalid e-mail'
    assert_equal nil, User.find_by_name('csail'), 'team profile name'
    assert_equal nil, User.find_by_name(nil)
  end
  
  test 'chargeable_profiles' do
    @user.save!
    assert_equal [], @user.chargeable_profiles
    assert_equal [profiles(:dexter)], profiles(:dexter).user.chargeable_profiles
  end
  
  test 'auth_bounce_reason' do
    assert_equal :blocked,
        users(:costan).auth_bounce_reason(credentials(:costan_email))
    assert_equal nil,
        users(:dexter).auth_bounce_reason(credentials(:dexter_email))
  end
  
  test 'profiles' do
    @user.save!
    assert_equal [], @user.profiles
    costan = users(:costan)
    assert_equal Set.new([profiles(:costan), profiles(:csail), profiles(:mit)]),
                 Set.new(costan.profiles)
    sam = users(:sam)
    assert_equal [profiles(:csail)], sam.profiles
  end
  
  test 'team_profiles' do
    @user.save!
    assert_equal [], @user.team_profiles
    costan = users(:costan)
    assert_equal [profiles(:csail), profiles(:mit)], costan.team_profiles
    sam = users(:sam)
    assert_equal [profiles(:csail)], sam.team_profiles
  end
  
  test 'team_repositories' do
    assert_equal [repositories(:csail_ghost)], users(:costan).team_repositories
  end

  test 'no acl for user with no profile' do
    assert_no_difference 'AclEntry.count' do
      @user.save!
    end
  end
  
  test 'acl for user with profile' do
    @user.profile = profiles(:csail)
    @user.save!
    assert_equal :edit, AclEntry.get(@user, @user.profile)
  end
  
  test 'acl for user profile change' do
    user = users(:dexter)
    assert user.profile
    user.profile = profiles(:csail)
    assert_no_difference 'AclEntry.count' do
      user.save!
    end
    assert_equal :edit, AclEntry.get(user, user.profile)
  end

  test 'acl deletion for user profile removal' do
    user = users(:dexter)
    assert user.profile
    user.profile = nil
    assert_difference 'AclEntry.count', -1 do
      user.save!
    end
  end
  
  test 'mass-assignment protection' do
    {
      :profile_id => 42, :profile => profiles(:csail),
    }.each do |attr, value|
      assert_raise ActiveModel::MassAssignmentSecurity::Error, attr.inspect do
        user = User.new attr => value
      end
    end
  end  
end
