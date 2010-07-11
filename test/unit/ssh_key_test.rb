require 'test_helper'

class SshKeyTest < ActiveSupport::TestCase
  def setup
    key_path = Rails.root.join 'test', 'fixtures', 'ssh_keys', 'new_key.pub'
    @key = SshKey.new :name => 'Some name', :key_line => File.read(key_path)
  end
  
  test 'setup' do
    assert @key.valid?
  end
    
  test 'key uniqueness' do
    @key.key_line = ssh_keys(:rsa).key_line
    assert !@key.valid?
  end
end
