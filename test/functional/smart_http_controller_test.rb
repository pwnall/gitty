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
    assert_equal 'ref: refs/heads/master', response.body
    assert_equal 'text/plain', response.headers['Content-Type']
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
