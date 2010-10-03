require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.new :email => 'john@doe.com', :password => 'password'    
  end
  
  test 'setup' do
    assert @user.valid?
  end
  
  test 'chargeable_profiles' do
    assert_equal [], @user.chargeable_profiles
    assert_equal [profiles(:dexter)], profiles(:dexter).user.chargeable_profiles
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
    user = users(:john)
    assert user.profile
    user.profile = profiles(:csail)
    assert_no_difference 'AclEntry.count' do
      user.save!
    end
    assert_equal :edit, AclEntry.get(user, user.profile)
  end

  test 'acl deletion for user profile removal' do
    user = users(:john)
    assert user.profile
    user.profile = nil
    assert_difference 'AclEntry.count', -1 do
      user.save!
    end
  end
end
