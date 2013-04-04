class SmartHttpController < ApplicationController
  # TODO(pwnall): figure out some CSRF protection
  skip_before_filter :verify_authenticity_token

  # Rejecting session cookies slightly mitigates the risk of CSRF. Users might
  # still type their credentials into the auth window popped out by the
  # browser, but we'll deal with that later.
  skip_before_filter :authenticate_using_session, except: :index

  # Git is capable of using this to authenticate over HTTP.
  authenticates_using_http_basic

  before_filter :http_user_can_read_repo, except: [:index, :receive_pack]
  before_filter :http_user_can_commit_to_repo, only: [:receive_pack]

  # GET costan/rails.git
  def index
    @profile = Profile.where(name: params[:profile_name]).first!
    @repository = @profile.repositories.where(name: params[:repo_name]).first!
    redirect_to profile_repository_path(@profile, @repository)
  end

  # GET costan/rails.git/info/refs
  def info_refs
    command = git_command
    unless command
      # Using the dumb HTTP protocol.
      params[:path] = 'info/refs'
      return git_file
    end

    output = @repository.run_command('git', [command, '--stateless-rpc',
                                             '--advertise-refs', '.'])
    git_header = "# service=#{params[:service]}\n"
    data = ['%04x' % (git_header.length + 4), git_header, '0000',
            output].join ''
    send_data data, type: "application/x-git-#{command}-advertisement"
  end

  # GET costan/rails.git/....
  def git_file
    file_path = @repository.internal_file_path params[:path]
    mime_type = @repository.internal_file_mime_type params[:path]
    if File.exist?(file_path)
      send_file file_path, type: mime_type
    else
      head :not_found
    end
  end

  # POST costan/rails.git/git-upload-pack
  def upload_pack
    self.headers['Content-Type'] = 'application/x-git-upload-pack-result'
    self.response_body = @repository.stream_command 'git', ['upload-pack',
        '--stateless-rpc', '.'], request.body
  end

  # POST costan/rails.git/git-receive-pack
  def receive_pack
    self.headers['Content-Type'] = 'application/x-git-receive-pack-result'
    command_streamer = @repository.stream_command 'git', ['receive-pack',
        '--stateless-rpc', '.'], request.body do
      @repository.record_push current_user
    end
    self.response_body = command_streamer
    # TODO(pwnall): update repository state
  end

  # The git command targeted by the HTTP request.
  def git_command
    case params[:service]
    when 'git-receive-pack'
      'receive-pack'
    when 'git-upload-pack'
      'upload-pack'
    else
      nil
    end
  end
  private :git_command
end
