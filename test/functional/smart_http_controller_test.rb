require 'test_helper'

class SmartHttpControllerTest < ActionController::TestCase
  setup :mock_any_repository_path
  
  setup do
    @repo = repositories(:dexter_ghost)
    @profile = @repo.profile
  end

  test 'HEAD' do
    get :git_file, :profile_name => @profile.to_param,
                   :repo_name => @repo.to_param, :path => 'HEAD'
    assert_response :success
    assert_equal "ref: refs/heads/master\n", response.body
    assert_equal 'text/plain', response.headers['Content-Type']
  end

  test 'dumb git pack fetch' do
    path = 'objects/pack/pack-7f67317db46e457c4fa046b22d8e87593c40a625.pack'
    get :git_file, :profile_name => @profile.to_param,
                   :repo_name => @repo.to_param, :path => path
  
    assert_response :success
    assert_equal response.body[0, 4], 'PACK'
    assert_equal 'application/x-git-packed-objects',
                 response.headers['Content-Type']
  end

  test 'dumb info/refs' do
    get :info_refs, :profile_name => @profile.to_param,
                    :repo_name => @repo.to_param
    assert_response :success
    assert_includes response.body,
        "88ca4433d478d6abb6558bebb9524fb72300457e\trefs/heads/master\n"
    assert_equal 'text/plain; charset=utf-8', response.headers['Content-Type']
  end

  test 'smart info/refs for git-upload-pack' do
    get :info_refs, :profile_name => @profile.to_param,
                    :repo_name => @repo.to_param,
                    :service => 'git-upload-pack'
    assert_response :success
    assert_equal "001e# service=git-upload-pack\n0000", response.body[0, 34],
                 'Incorrect response header'
    assert_includes response.body,
        "003f88ca4433d478d6abb6558bebb9524fb72300457e refs/heads/master\n",
        "Response doesn't include the master branch"
    assert_equal 'application/x-git-upload-pack-advertisement',
                 response.headers['Content-Type']
  end

  test 'smart info/refs for git-receive-pack' do
    get :info_refs, :profile_name => @profile.to_param,
                    :repo_name => @repo.to_param,
                    :service => 'git-receive-pack'
    assert_response :success
    assert_equal "001f# service=git-receive-pack\n0000", response.body[0, 35],
                 'Incorrect response header'
    assert_includes response.body,
        "003f88ca4433d478d6abb6558bebb9524fb72300457e refs/heads/master\n",
        "Response doesn't include the master branch"
    assert_equal 'application/x-git-receive-pack-advertisement',
                 response.headers['Content-Type']
  end

  test 'null upload-pack' do
    @request.env['RAW_POST_DATA'] = "0000"
    @request.headers['CONTENT-TYPE'] = 'application/x-git-upload-pack-request'
    post :upload_pack, :profile_name => @profile.to_param,
                       :repo_name => @repo.to_param
    assert_response :success
    assert_equal '', response.body
    assert_equal 'application/x-git-upload-pack-result',
                 response.headers['Content-Type']
  end

  test 'upload-pack' do
    @request.env['RAW_POST_DATA'] = "006fwant 88ca4433d478d6abb6558bebb9524fb72300457e multi_ack_detailed no-done side-band-64k thin-pack ofs-delta\n0032want 88ca4433d478d6abb6558bebb9524fb72300457e\n00000009done\n"
    @request.headers['Content-Type'] = 'application/x-git-upload-pack-request'
    post :upload_pack, :profile_name => @profile.to_param,
                       :repo_name => @repo.to_param
    assert_response :success
    body = response.body
    assert_include body, 'Counting objects'
    assert_include body, 'PACK'
    assert_equal 'application/x-git-upload-pack-result',
                 response.headers['Content-Type']
  end

  test 'null receive-pack' do
    @request.env['RAW_POST_DATA'] = '0000'
    @request.headers['Content-Type'] = 'application/x-git-receive-pack-request'
    post :receive_pack, :profile_name => @profile.to_param,
                        :repo_name => @repo.to_param
    assert_response :success
    assert_equal '', response.body
    assert_equal 'application/x-git-receive-pack-result',
                 response.headers['Content-Type']
  end

  test 'smart http routes' do
    assert_routing({:path => '/costan/rails.git/info/refs', :method => :get},
                   {:controller => 'smart_http', :action => 'info_refs',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails.git/HEAD', :method => :get},
                   {:controller => 'smart_http', :action => 'git_file',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :path => 'HEAD'})
    assert_routing({:path => '/costan/rails.git/objects/info/http-alternates',
                    :method => :get},
                   {:controller => 'smart_http', :action => 'git_file',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :path => 'objects/info/http-alternates'})
    assert_routing({:path => '/costan/rails.git/objects/pack/pack-12345.pack',
                    :method => :get},
                   {:controller => 'smart_http', :action => 'git_file',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :path => 'objects/pack/pack-12345.pack'})
    assert_routing({:path => '/costan/rails.git/git-upload-pack',
                    :method => :post},
                   {:controller => 'smart_http', :action => 'upload_pack',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails.git/git-receive-pack',
                    :method => :post},
                   {:controller => 'smart_http', :action => 'receive_pack',
                    :profile_name => 'costan', :repo_name => 'rails'})
  end
end
