class ActiveSupport::TestCase
  # Override the local repository path so it's in a temp directory.
  def mock_profile_paths
    return if Profile.respond_to?(:real_local_path)

    repo_root = Rails.root.join 'tmp', 'test_git_root'
    FileUtils.rm_r repo_root if File.exists?(repo_root)   
    FileUtils.mkdir_p repo_root    

    Profile.class_eval do
      (class <<self; self; end).class_eval do
        alias_method :real_local_path, :local_path
        define_method :local_path do |name|
          repo_root.join(name).to_s
        end
      end
    end    
  end
  
  # Revert to the real local repository path implementation.
  def mock_profile_paths_undo
    return unless Profile.respond_to?(:real_local_path)
    
    Profile.class_eval do
      (class <<self; self; end).class_eval do
        undef local_path
        alias_method :local_path, :real_local_path
        undef real_local_path
      end
    end
  end
end
