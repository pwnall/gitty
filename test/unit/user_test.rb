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
end
