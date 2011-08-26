require 'test_helper'

require 'net/http'

class GitShellExecutorTest < ActiveSupport::TestCase
  # Raised by the mock error method.
  class ShellExitError < RuntimeError; end
  class GitExitError < RuntimeError; end
  class AccessExitError < RuntimeError; end
  class BackendExitError < RuntimeError; end
  
  setup do
    @executor = GitShellExecutor.new
    # Mock the error method.
    class <<@executor
      def error(message)
        case message
        when /git\+ssh/
          raise ShellExitError, message
        when /Git/
          raise GitExitError, message
        when /Access/
          raise AccessExitError, message
        when /Backend/
          raise BackendExitError, message
        end
      end
    end
    
    @key_id = ssh_keys(:rsa).to_param
    @server = 'http://test:1234/'
    @backend = 'http://test:1234/_'
    @repo = repositories(:dexter_ghost)
    @repo_path = @repo.profile.name + '/' + @repo.name + '.git'
    @repo_dir = 'repos/' + @repo_path
  end
  
  test 'invalid command' do
    assert_raise ShellExitError do
      @executor.run [@key_id, @server, 'ls', '-l']
    end
  end
  
  test 'garbage parameters' do
    assert_raise ShellExitError do
      @executor.run [@key_id, @server, 'git-upload-pack', @repo_path, '--bsbs']
    end
  end
  
  test 'access denied pull' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=false"
    @executor.expects(:app_request).with(nil, @backend, app_req).
        returns('{"access": false, "message": "no such repository"}').once
        
    assert_raise AccessExitError do
      @executor.run [@key_id, @server, 'git-upload-pack', @repo_path]
    end
  end
  
  test 'access denied push' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=true"
    @executor.expects(:app_request).with(nil, @backend, app_req).
        returns('{"access": false, "message": "no such repository"}').once
        
    assert_raise AccessExitError do
      @executor.run [@key_id, @server, 'git-receive-pack', @repo_path]
    end
  end
  
  test 'successful pull' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=false"
    @executor.expects(:app_request).with(nil, @backend, app_req).
              returns('{"access": true}').once
    @executor.expects(:exec_git).with('git-upload-archive', @repo_dir).
              returns(true).once
    File.expects(:umask).once.with(0002).returns(0666)
    File.expects(:umask).once.with(0666).returns(0002)

    @executor.run [@key_id, @server, 'git-upload-archive', @repo_path]
  end

  test 'failed pull' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=false"
    @executor.expects(:app_request).with(nil, @backend, app_req).
              returns('{"access": true}').once
    @executor.expects(:exec_git).with('git-upload-archive', @repo_dir).
              returns(false).once
    File.expects(:umask).once.with(0002).returns(0666)
    File.expects(:umask).once.with(0666).returns(0002)

    assert_raise GitExitError do        
      @executor.run [@key_id, @server, 'git-upload-archive', @repo_path]
    end
  end
  
  test 'successful push' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=true"
    @executor.expects(:app_request).with(nil, @backend, app_req).
              returns('{"access": true}').once
    @executor.expects(:exec_git).once.with('git-receive-pack', @repo_dir).
              returns(true)
    app_req = "change_notice.json"
    @executor.expects(:app_request).
        with({'repo_path' => @repo_path, 'ssh_key_id' => @key_id}, @backend,
             app_req).returns('{"success": true}').once
    File.expects(:umask).once.with(0002).returns(0666)
    File.expects(:umask).once.with(0666).returns(0002)
    @executor.run [@key_id, @server, 'git-receive-pack', @repo_path]
  end

  test 'un-acknowledged push' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=true"
    @executor.expects(:app_request).with(nil, @backend, app_req).
              returns('{"access": true}').once
    @executor.expects(:exec_git).once.with('git-receive-pack', @repo_dir).
              returns(true)
    app_req = "change_notice.json"
    @executor.expects(:app_request).
        with({'repo_path' => @repo_path, 'ssh_key_id' => @key_id},
             @backend, app_req).returns('{"success": false}').times(3)
    File.expects(:umask).once.with(0002).returns(0666)
    File.expects(:umask).once.with(0666).returns(0002)
    assert_raise BackendExitError do
      @executor.run [@key_id, @server, 'git-receive-pack', @repo_path]
    end    
  end
  
  test 'app request get' do
    @server = 'http://test:1234'
    Net::HTTP.expects(:get).with(URI.parse("http://test:1234/_/g.json?p=true")).
              returns('HTTP response').once
    assert_equal 'HTTP response',
                  @executor.app_request(false, @backend, 'g.json?p=true')
  end

  test 'app request broken get' do
    @server = 'http://test:1234'
    Net::HTTP.expects(:get).
              with(URI.parse("http://test:1234/_/get.json?p=true")).
              raises(RuntimeError).once
    assert_raise BackendExitError do
      @executor.app_request(nil, @backend, 'get.json?p=true')
    end
  end

  test 'app request post' do
    response = Object.new
    response.expects(:body).returns('HTTP response').once
    Net::HTTP.expects(:post_form).once.
              with(URI.parse("http://test:1234/_/check_access.json"), {}).
              returns(response)
    assert_equal 'HTTP response',
                  @executor.app_request({}, @backend, 'check_access.json')
  end  
end
