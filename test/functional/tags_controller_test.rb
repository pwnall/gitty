require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    @tag = tags(:unicorns)
    @session_user = @tag.repository.profile.user
    set_session_current_user @session_user
  end

  test "should get index" do
    get :index, :repo_name => @tag.repository.to_param,
                :profile_name => @tag.repository.profile.to_param
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  test "should show tag" do
    get :show, :tag_name => @tag.to_param,
               :repo_name => @tag.repository.to_param,
               :profile_name => @tag.repository.profile.to_param
    assert_response :success
  end
  
  test "should grant read access to non-owner" do
    non_owner = User.all.find { |u| u != @session_user }
    assert non_owner, 'non-owner finding failed'
    set_session_current_user non_owner

    get :index, :repo_name => @tag.repository.to_param,
                :profile_name => @tag.repository.profile.to_param
    assert_response :success
    
    get :show, :tag_name => @tag.to_param,
               :repo_name => @tag.repository.to_param,
               :profile_name => @tag.repository.profile.to_param
    assert_response :success
  end

  test "should deny access to guests" do
    set_session_current_user nil
    
    get :index, :repo_name => @tag.repository.to_param,
                :profile_name => @tag.repository.profile.to_param
    assert_response :forbidden
    
    get :show, :tag_name => @tag.to_param,
               :repo_name => @tag.repository.to_param,
               :profile_name => @tag.repository.profile.to_param
    assert_response :forbidden
  end  

  test "tag routes" do
    assert_routing({:path => '/costan/rails/tags', :method => :get},
                   {:controller => 'tags', :action => 'index',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails/tag/v1.0',
                    :method => :get},
                   {:controller => 'tags', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :tag_name => 'v1.0'})
  end
end
