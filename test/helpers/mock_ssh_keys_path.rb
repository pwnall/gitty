class ActiveSupport::TestCase
  # Override the authorized_keys path so it's in a temp directory.
  def mock_ssh_keys_path
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
  end
  
  # Revert to the real local repository path implementation.
  def mock_ssh_keys_path_undo
    return unless SshKey.respond_to?(:real_keyfile_path)
    
    SshKey.class_eval do
      (class <<self; self; end).class_eval do
        undef keyfile_path
        alias_method :keyfile_path, :real_keyfile_path
        undef real_keyfile_path
      end
    end
  end  
end
