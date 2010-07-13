# Implements the customized git-shell.
class GitShellExecutor
  # The shell script is a wrapper around this method.
  def run(args)
    read_args args
    check_access @repository, @ssh_key_id, @commit_access
    success = exec_git(@command, "repos/" + @repository)
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

    quotes = ["'", '"']
    if quotes.include?(@repository[0, 1]) && quotes.include?(@repository[-1, 1])
      @repository = @repository[1...-1]
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
    request = "check_access.json?repo_path=#{URI.encode repository}&" +
              "ssh_key_id=#{key_id}&commit=#{commit_access}"
    response = begin
      JSON.parse app_request(nil, @backend_url, request)
    rescue JSON::JSONError
      error "Backend server error, please retry later."
    end
    error "Access denied: #{response['message']}" unless response['access']
  end
  
  # Notifies the application server that a repository has changed.
  def notify_server(repository)
    3.times do
      body = app_request({'repo_path' => repository}, @backend_url,
                         'change_notice.json')
      response = JSON.parse(body) rescue {}
      return if response['success']
    end
    error 'Backend server error, please retry later.'
  end
  
  # Performs a HTTP request to the application server.
  #
  # Returns the response's body.
  def app_request(post_data, backend_url, request)
    request_uri = URI.parse File.join(backend_url, request)
    begin
      if post_data
        Net::HTTP.post_form(request_uri, post_data).body
      else
        Net::HTTP.get request_uri
      end
    rescue
      error 'Backend server down, please retry later.'
    end
  end
  
  # Aborts the shell due to an error.
  def error(error_text)
    STDERR.puts error_text + "\r\n"
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
        pid, status = *Process.wait2(child_pid)
        return status.exitstatus == 0 if pid == child_pid
      end
    end
  end  
end
