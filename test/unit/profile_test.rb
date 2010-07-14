require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  def setup
    @profile = Profile.new :name => 'awesome',
                           :display_name => 'Awesome Profile'
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
end
