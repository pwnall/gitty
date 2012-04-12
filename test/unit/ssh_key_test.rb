require 'test_helper'

class SshKeyTest < ActiveSupport::TestCase
  setup :mock_ssh_keys_path

  setup do
    @key_path = Rails.root.join 'test', 'fixtures', 'ssh_keys', 'new_key.pub'
    @key = SshKey.new :name => 'Some name', :key_line => File.read(@key_path),
                      :user => users(:dexter)
  end
    
  test 'setup' do
    assert @key.valid?
  end

  test 'user has to be set' do
    @key.user = nil
    assert !@key.valid?
  end

  test 'key uniqueness' do
    @key.key_line = ssh_keys(:rsa).key_line
    assert !@key.valid?
  end
  
  test 'fingerprint' do
    rsa_fprint = SshKey.fingerprint ssh_keys(:rsa).key_line
    dsa_fprint = SshKey.fingerprint ssh_keys(:dsa).key_line
    invalid_fprint = SshKey.fingerprint 'invalid keyline'
    noise_fprint = SshKey.fingerprint '#$%@!#$!@#$!@# #$@!#%!@#$%!@# #@$!@#$!@'
    null_fprint = SshKey.fingerprint ''
    
    assert_not_equal rsa_fprint, dsa_fprint, 'RSA != DSA'
    assert_not_equal rsa_fprint, invalid_fprint, 'RSA != invalid keyline'
    assert_not_equal rsa_fprint, noise_fprint, 'RSA != line noise keyline'
    assert_not_equal rsa_fprint, null_fprint, 'RSA != empty keyline'
    assert_not_equal dsa_fprint, invalid_fprint, 'RSA != invalid keyline'
    assert_not_equal dsa_fprint, noise_fprint, 'DSA != line noise keyline'
    assert_not_equal dsa_fprint, null_fprint, 'RSA != empty keyline'
  end

  test 'original keyfile_path' do
    mock_ssh_keys_path_undo
    if RUBY_PLATFORM =~ /darwin/
      assert_equal '/Users/git-test/repos/.ssh_keys', SshKey.keyfile_path
    else      
      assert_equal '/home/git-test/repos/.ssh_keys', SshKey.keyfile_path
    end
  end
  
  test 'keyline works around Windows CRLF' do
    win_keyfile = File.read(@key_path)
    win_keyfile[100, 0] = "\r\n"
    win_key = SshKey.new :key_line => win_keyfile
    assert_equal @key.fprint, win_key.fprint
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
  
  test 'model-keyfile lifetime sync' do    
    @key.save!
    assert File.readlines('tmp/test_git_root/.ssh_keys').
                map(&:strip).include?(@key.keyfile_line),
           'keyfile does not contain a line for the new key'
    
    @key.destroy    
    assert !File.readlines('tmp/test_git_root/.ssh_keys').
                 map(&:strip).include?(@key.keyfile_line),
           'keyfile still has a line for the destroyed key'
  end
end
