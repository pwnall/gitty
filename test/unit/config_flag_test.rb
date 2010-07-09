require 'test_helper'

class ConfigFlagTest < ActiveSupport::TestCase
  def setup
    @flag = ConfigFlag.new :name => 'flag', :value => 'flag_value'
  end
  
  test "setup" do
    assert @flag.valid?
  end
  
  test "duplicate flag name" do
    @flag.name = 'git_user'
    assert !@flag.valid?
  end

  test "convenience get" do
    @flag.save!
    assert_equal 'flag_value', ConfigFlag['flag']
  end
  
  test "convenience set" do
    ConfigFlag['other_flag'] = 'other_value'
    assert_equal 'other_value',
                 ConfigFlag.select(:name => 'other_flag').first.value
  end
end
