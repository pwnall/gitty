require 'test_helper'
require 'net/http'

class GitPushTest < ActionDispatch::IntegrationTest
  fixtures :all

  self.use_transactional_fixtures = false

  def setup
    @temp_dir = Rails.root.join 'tmp', 'git_client'
    FileUtils.mkdir_p @temp_dir

    # NOTE: starting Rails first, so it has time to boot.
    @webapp_pid_file = @temp_dir.join 'webapp.pid'
    @webapp_log_file = @temp_dir.join 'thin.log'
    Kernel.system 'bundle', 'exec', 'thin', 'start', '--daemonize',
                  '--quiet', '--environment', 'test',
                  '--port', ConfigVar['app_uri'].split(':').last[0...-1],
                  '--pid', @webapp_pid_file.to_s,
                  '--log', @webapp_log_file.to_s

    @user_scripts_path = Rails.root.join 'script', 'git_user'
    setup_script = @user_scripts_path.join('setup').to_s
    Kernel.system 'sudo', setup_script, ConfigVar['git_user'], Etc.getlogin
    SshKey.write_keyfile

    @win_repository = Repository.new :name => 'rwin'
    @win_repository.profile = profiles(:dexter)
    @win_repository.save!
    @fail_repository = Repository.new :name => 'rfail'
    @fail_repository.profile = profiles(:dexter)
    @fail_repository.save!

    @keyfile = Rails.root.join 'test', 'fixtures', 'ssh_keys', 'id_dsa'
    File.chmod 0600, @keyfile  # NOTE: ssh 0.9.8o gets bitchy otherwise
    ssh_wrapper = @temp_dir.join('git-ssh.sh').to_s
    File.open ssh_wrapper, 'w' do |f|
      options = '-o PasswordAuthentication=no -o PubkeyAuthentication=yes ' +
                '-o UserKnownHostsFile=/dev/null ' +
                '-o StrictHostKeyChecking=no -o LogLevel=ERROR'
      f.write <<END_SHELL
#!/bin/sh
exec ssh -i "#{@keyfile}" #{options} "$@"
END_SHELL
    end
    File.chmod 0755, ssh_wrapper
    @old_env_git_ssh = ENV['GIT_SSH']
    ENV['GIT_SSH'] = ssh_wrapper

    @fixture_repo_path = Rails.root.join 'test', 'fixtures', 'repo.git'

    wait_for_server_start
  end

  # Wait until the Rails server has booted.
  def wait_for_server_start
    deadline = Time.now + 30.seconds
    loop do
      begin
        Net::HTTP.get URI.parse(ConfigVar['app_uri'])
        break
      rescue Exception => e
        if Time.now >= deadline
          log = File.read @webapp_log_file
          raise "Web server failed to start! Log:\n#{log}\n"
        end
        sleep 0.1
      end
    end
  end

  def teardown
    if @webapp_pid_file
      Kernel.system 'thin', 'stop', '--pid', @webapp_pid_file.to_s
    end

    FileUtils.rm_r @temp_dir.to_s
    ENV['GIT_SSH'] = @old_env_git_ssh

    teardown_script = @user_scripts_path.join('teardown').to_s
    Kernel.system teardown_script, ConfigVar['git_user'], Etc.getlogin
  end

  test "initial repository push and delete" do
    Dir.chdir @temp_dir do
      assert Kernel.system('git init -q'), 'Failed to initialize repository'
      assert Kernel.system("git remote add origin #{@win_repository.ssh_uri}"),
             'Failed to add remote'
      add_commit_push
    end
    @win_repository.destroy
    assert !File.exist?(@win_repository.local_path),
           'Failed to remove repository'
  end

  test "repository clone push and delete" do
    FileUtils.rm_r @win_repository.local_path
    FileUtils.cp_r @fixture_repo_path, @win_repository.local_path
    FileUtils.chmod_R 0770, @win_repository.local_path


    Dir.chdir @temp_dir do
      assert Kernel.system("git clone -q #{@win_repository.ssh_uri}"),
             'Failed to clone repository'
      FileUtils.cp 'git-ssh.sh', 'rwin'
      Dir.chdir 'rwin' do
        add_commit_push
      end

      assert_equal 'Integration test commit',
          @win_repository.branches.where(:name => 'master').first.commit.
                          message, 'Pushed branches not assimilated'
      assert_equal 'Integration test tag',
          @win_repository.tags.where(:name => 'integration').first.message
          'Pushed tags not assimilated'
    end
    @win_repository.destroy
    assert !File.exist?(@win_repository.local_path),
           'Failed to remove repository'
  end

  def add_commit_push
    assert Kernel.system('git add -A'), 'Failed to add initial content'
    assert Kernel.system('git commit -a -q -m "Integration test commit"'),
           'Failed to make test commit'
    assert Kernel.system('git tag -m "Integration test tag" integration'),
           'Failed to make test tag'
    assert Kernel.system('git push -q --tags origin master'),
           'Git push failed'
  end

  test "repository http clone push and delete" do
    FileUtils.rm_r @win_repository.local_path
    FileUtils.cp_r @fixture_repo_path, @win_repository.local_path
    FileUtils.chmod_R 0770, @win_repository.local_path

    http_url = File.join ConfigVar['app_uri'],
        git_over_http_path(@win_repository.profile, @win_repository)
    # Hacky way of embedding username:password.
    user = @win_repository.profile.user
    http_url.sub! '://', "://#{CGI.escape(user.email)}:pa55w0rd@"

    Dir.chdir @temp_dir do
      assert Kernel.system("git clone -q #{http_url}"),
             'Failed to clone repository'
      FileUtils.cp 'git-ssh.sh', 'rwin'
      Dir.chdir 'rwin' do
        add_commit_push
      end

      assert_equal 'Integration test commit',
          @win_repository.branches.where(:name => 'master').first.commit.
                          message, 'Pushed branches not assimilated'
      assert_equal 'Integration test tag',
          @win_repository.tags.where(:name => 'integration').first.message
          'Pushed tags not assimilated'
    end
    @win_repository.destroy
    assert !File.exist?(@win_repository.local_path),
           'Failed to remove repository'
  end
end

