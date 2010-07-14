require 'test_helper'

class GitPushTest < ActionDispatch::IntegrationTest
  fixtures :all

  def setup
    @temp_dir = Rails.root.join 'tmp', 'git_client'
    FileUtils.mkdir_p @temp_dir

    # NOTE: starting Rails first, so it has time to boot.
    @webapp_pid_file = @temp_dir.join 'webapp.pid'
    Kernel.system 'thin', 'start', '--daemonize', '--environment', 'test',
                  '--port', ConfigFlag['app_uri'].split(':').last[0...-1],
                  '--pid', @webapp_pid_file.to_s,
                  '--log', @temp_dir.join('thin.log')

    @user_scripts_path = Rails.root.join 'script', 'git_user'
    setup_script = @user_scripts_path.join 'setup'
    Kernel.system 'sudo', setup_script, ConfigFlag['git_user'], Etc.getlogin
    SshKey.write_keyfile
  
    @win_repository = Repository.create! :name => 'rwin',
                                         :profile => profiles(:dexter)
    @fail_repository = Repository.create! :name => 'rfail',
                                         :profile => profiles(:dexter)

    @keyfile = Rails.root.join 'test', 'fixtures', 'ssh_keys', 'id_rsa'
    ssh_wrapper = File.join(@temp_dir, 'git-ssh.sh')
    File.open ssh_wrapper, 'w' do |f|
      options = '-o PasswordAuthentication=no -o PubkeyAuthentication=yes'
      f.write <<END_SHELL
#!/bin/sh
exec ssh -i "#{@keyfile}" #{options} "$@"
END_SHELL
    end
    File.chmod 0700, ssh_wrapper
    
    @fixture_repo_path = Rails.root.join 'test', 'fixtures', 'repo.git'

    # Wait until the Rails server has booted.
    loop do
      begin
        Net::HTTP.get URI.parse(ConfigFlag['app_uri'])
        break
      rescue
        sleep 0.1
      end
    end
  end
  
  def teardown
    if @webapp_pid_file
      Kernel.system 'thin', 'stop', '--pid', @webapp_pid_file.to_s
    end
    
    FileUtils.rm_r @temp_dir if @temp_dir    
    
    teardown_script = @user_scripts_path.join 'teardown'
    Kernel.system teardown_script, ConfigFlag['git_user'], Etc.getlogin
  end

  test "initial repository push" do    
    Dir.chdir @temp_dir do      
      assert Kernel.system('git init'), 'Failed to initialize repository'
      assert Kernel.system("git remote add origin #{@win_repository.ssh_uri}"),
             'Failed to add remote'
      add_commit_push
    end
  end
    
  test "repository clone and push" do
    FileUtils.rm_r @win_repository.local_path
    FileUtils.cp_r @fixture_repo_path, @win_repository.local_path
    FileUtils.chmod_R 0770, @win_repository.local_path    
    
    Dir.chdir @temp_dir do
      assert Kernel.system("git clone #{@win_repository.ssh_uri}"),
             'Failed to clone repository'
      FileUtils.cp 'git-ssh.sh', 'rwin'
      Dir.chdir 'rwin' do
        add_commit_push
      end
    end
  end

  def add_commit_push
    assert Kernel.system('git add .'), 'Failed to add initial content'
    assert Kernel.system('git commit -a -m "Integration test commit"'),
           'Failed to make initial commit'
    ENV['GIT_SSH'] = './git-ssh.sh'
    assert Kernel.system('git push origin master'),
           'Git push failed'
  end
end
