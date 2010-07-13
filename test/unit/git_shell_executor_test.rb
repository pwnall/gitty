require 'test_helper'

class GitShellExecutorTest < ActiveSupport::TestCase
  # Raised by the mock error method.
  class ShellExitError < RuntimeError; end
  class GitExitError < RuntimeError; end
  class AccessExitError < RuntimeError; end
  class BackendExitError < RuntimeError; end
  
  def setup
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
    @repo = repositories(:ghost)
    @repo_path = @repo.name + 'repo_uri'
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
    flexmock(@executor).should_receive(:app_request).
        with(nil, @server, app_req).
        and_return('{"access": false, "message": "no such repository"}').once
        
    assert_raise AccessExitError do
      @executor.run [@key_id, @server, 'git-upload-pack', @repo_path]
    end
  end
  
  test 'access denied push' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=true"
    flexmock(@executor).should_receive(:app_request).
        with(nil, @server, app_req).
        and_return('{"access": false, "message": "no such repository"}').once
        
    assert_raise AccessExitError do
      @executor.run [@key_id, @server, 'git-receive-pack', @repo_path]
    end
  end
  
  test 'successful pull' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=false"
    flexmock(@executor).should_receive(:app_request).
                        with(nil, @server, app_req).
                        and_return('{"access": true}').once
    flexmock(@executor).should_receive(:exec_git).
                        with('git-upload-archive', @repo_dir).and_return(true).
                        once
        
    @executor.run [@key_id, @server, 'git-upload-archive', @repo_path]
  end

  test 'failed pull' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=false"
    flexmock(@executor).should_receive(:app_request).
                        with(nil, @server, app_req).
                        and_return('{"access": true}').once
    flexmock(@executor).should_receive(:exec_git).once.
                        with('git-upload-archive', @repo_dir).and_return(false)

    assert_raise GitExitError do        
      @executor.run [@key_id, @server, 'git-upload-archive', @repo_path]
    end
  end
  
  test 'successful push' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=true"
    flexmock(@executor).should_receive(:app_request).
                        with(nil, @server, app_req).
                        and_return('{"access": true}').once
    flexmock(@executor).should_receive(:exec_git).once.
                        with('git-receive-pack', @repo_dir).and_return(true)
    app_req = "change_notice.json"
    flexmock(@executor).should_receive(:app_request).
                        with({'repo_path' => @repo_path}, @server, app_req).
                        and_return('{"success": true}').once
    @executor.run [@key_id, @server, 'git-receive-pack', @repo_path]
  end

  test 'un-acknowledged push' do
    app_req = "check_access.json?repo_path=#{@repo_path}&" +
              "ssh_key_id=#{@key_id}&commit=true"
    flexmock(@executor).should_receive(:app_request).
                        with(nil, @server, app_req).
                        and_return('{"access": true}').once
    flexmock(@executor).should_receive(:exec_git).once.
                        with('git-receive-pack', @repo_dir).and_return(true)
    app_req = "change_notice.json"
    flexmock(@executor).should_receive(:app_request).
                        with({'repo_path' => @repo_path}, @server, app_req).
                        and_return('{"success": false}').times(3)
    assert_raise BackendExitError do
      @executor.run [@key_id, @server, 'git-receive-pack', @repo_path]
    end    
  end
  
  test 'app request get' do
    @server = 'http://test:1234'
    flexmock(Net::HTTP).should_receive(:get).once.
                        with(URI.parse("http://test:1234/get.json?p=true")).
                        and_return('HTTP response')
    assert_equal 'HTTP response',
                  @executor.app_request(false, @server, 'get.json?p=true')
  end

  test 'app request broken get' do
    @server = 'http://test:1234'
    flexmock(Net::HTTP).should_receive(:get).once.
                        with(URI.parse("http://test:1234/get.json?p=true")).
                        and_raise(RuntimeError)
    assert_raise BackendExitError do
      @executor.app_request(nil, @server, 'get.json?p=true')
    end
  end

  test 'app request post' do
    response = Object.new
    flexmock(response).should_receive(:body).and_return('HTTP response').once
    flexmock(Net::HTTP).should_receive(:post_form).once.
        with(URI.parse("http://test:1234/check_access.json"), {}).
        and_return(response)
    assert_equal 'HTTP response',
                  @executor.app_request({}, @server, 'check_access.json')
  end  
end
