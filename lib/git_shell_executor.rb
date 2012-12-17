# Implements the customized git-shell.
class GitShellExecutor
  # The shell script is a wrapper around this method.
  def run(args)
    read_args args
    check_access @repository, @ssh_key_id, @commit_access
    success = exec_git_with_umask @command, "repos/" + @repository, 0002
    error 'Git operation failed.' unless success
    notify_server @repository, @ssh_key_id if @commit_access
  end

  # Decodes and checks the command-line arguments received by the git-shell.
  #
  # If the arguments are incorrect, the shell is terminated by a call to
  # GitShellExecutor#error.
  def read_args(args)
    @ssh_key_id = args[0]
    @backend_url = File.join args[1], '_'
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
  def notify_server(repository, key_id)
    3.times do
      body = app_request({'repo_path' => repository, 'ssh_key_id' => key_id},
                         @backend_url, 'change_notice.json')
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
    http = Net::HTTP.new request_uri.host, request_uri.port
    if request_uri.scheme == 'https'
      http.use_ssl = true
    end
    request_path = request_uri.path
    request_path += "?#{request_uri.query}" if request_uri.query

    begin
      response = nil
      http.start do
        response = if post_data
          request = Net::HTTP::Post.new request_path
          request.form_data = post_data
          http.request request
        else
          http.get request_path
        end
      end
      response.body
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
  def exec_git_with_umask(command, repository, umask)
    old_umask = File.umask 0002
    begin
      exec_git command, repository
    ensure
      File.umask old_umask
    end
  end

  # Runs a git-shell command.
  #
  # Returns true if the command executed successfully, false otherwise.
  def exec_git(command, repository)
    unless child_pid = Process.fork
      # In child.

      # NOTE: on OSX, /usr/local/bin isn't on the path by default,
      #       and people install git there.
      ENV['PATH'] = ENV['PATH'] + ':/usr/local:/usr/local/bin'
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
