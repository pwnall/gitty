require 'test_helper'

class SshKeyTest < ActiveSupport::TestCase
  def setup
    key_path = Rails.root.join 'test', 'fixtures', 'ssh_keys', 'new_key.pub'
    @key = SshKey.new :name => 'Some name', :key_line => File.read(key_path),
                      :profile => profiles(:dexter)
  end
  
  # Override the authorized_keys path so it's in a temp directory.
  def mock_authorized_keys
    return if SshKey.respond_to?(:real_keyfile_path)
    
    ssh_path = Rails.root.join 'tmp', 'test_git_root'
    FileUtils.mkdir_p ssh_path
    
    SshKey.class_eval do
      (class <<self; self; end).class_eval do
        alias_method :real_keyfile_path, :keyfile_path
        define_method :keyfile_path do
          ssh_path.join('.ssh_keys').to_s
        end
      end
    end
    
    repo_root = Rails.root.join 'tmp', 'test_git_root'
    FileUtils.mkdir_p repo_root    
  end
  setup :mock_authorized_keys  
  
  test 'setup' do
    assert @key.valid?
  end

  test 'profile has to be set' do
    @key.profile = nil
    assert !@key.valid?
  end

  test 'key uniqueness' do
    @key.key_line = ssh_keys(:rsa).key_line
    assert !@key.valid?
  end

  test 'original keyfile_path' do
    assert_equal '/home/git-test/repos/.ssh_keys', SshKey.real_keyfile_path
  end
  
  test 'keyfile_line' do
    line = @key.keyfile_line
    assert_operator line, :index, @key.key_line,
                    'authorized_keys line does not contain key data'
    assert_operator line, :index, 'command=',
                    'authorized_keys line does not force a command'
    assert_operator line, :index, 'no-X11-forwarding',
                    'authorized_keys line does not shutdown port access'
  end
  
  test 'keyfile' do
    SshKey.write_keyfile
    
    assert File.exist?('tmp/test_git_root/.ssh_keys'),
           'keyfile not created'
    
    assert File.readlines('tmp/test_git_root/.ssh_keys').
                map(&:strip).include?(ssh_keys(:rsa).keyfile_line),
           'keyfile does not contain a line for the RSA key'
    
    File.unlink 'tmp/test_git_root/.ssh_keys'
  end
end
