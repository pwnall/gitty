# Implements the customized git-shell.
class GitShellExecutor
  # The shell script is a wrapper around this method.
  def run(args)
    read_args args
    check_access @repository, @ssh_key_id, @commit_access
    success = exec_git @command, @repository
    error 'Git operation failed.' unless success
    notify_server @repository if @commit_access
  end
  
  # Decodes and checks the command-line arguments received by the git-shell.
  #
  # If the arguments are incorrect, the shell is terminated by a call to
  # GitShellExecutor#error.
  def read_args(args)
    @ssh_key_id = args[0]
    @backend_url = args[1]
    @command = args[2]
    @repository = args[3]
    
    commands = ['git-receive-pack', 'git-upload-archive', 'git-upload-pack']
    commit_commands = ['git-receive-pack'] 

    if args.length != 4 || !commands.include?(@command)
      error 'This shell only accepts git+ssh.'
    else
      @commit_access = commit_commands.include? @command
    end
  end
  
  # Verifies that the owner of an SSH key is allowed to commit to a repository.
  #
  # Args:
  #   repository:: the path of the repository to check
  #   key_id:: the record ID of the owner's SSH key
  #   commit_access:: if false, only read access is desired
  #
  # If the owner doesn't have access to the repository, the shell is terminated
  # by a call to GitShellExecutor#error.
  def check_access(repository, key_id, commit_access)
    request = "check_access.json?repo_dir=#{URI.encode repository}&" +
              "ssh_key_id=#{key_id}&commit=#{commit_access}"
    response = JSON.parse app_request(false, @backend_url, request)
    error "Access denied: #{response['message']}" unless response['access']
  end
  
  # Notifies the application server that a repository has changed.
  def notify_server(repository)
    request = "change_notice.json?repo_dir=#{URI.encode(repository)}"
    3.times do
      response = JSON.parse app_request(true, @backend_url, request)
      return if response['success']
    end
    error 'Backend server error, please retry later.'
  end
  
  # Performs a HTTP request to the application server.
  #
  # Returns the response's body.
  def app_request(use_post, backend_url, request)
    request_uri = URI.parse File.join(backend_url, request)
    begin
      if use_post
        Net::HTTP.post request_uri
      else
        Net::HTTP.get request_uri
      end
    rescue
      error 'Backend server down, please retry later.'
    end
  end
  
  # Aborts the shell due to an error.
  def error(error_text)
    STDERR.puts error_text
    exit 1
  end
  
  # Runs a git-shell command.
  #
  # Returns true if the command executed successfully, false otherwise.
  def exec_git(command, repository)
    unless child_pid = Process.fork
      # In child.
      Kernel.exec command, repository
    else
      # In parent.
      loop do      
        pid, exit_status = *Process.waitpid(child_pid)
        return exit_status == 0 if pid == child_pid
      end
    end
  end  
end
