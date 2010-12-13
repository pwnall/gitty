require 'test_helper'

class FeedSubscriptionsControllerTest < ActionController::TestCase
  setup do
    @repository = repositories(:dexter_ghost)
    @profile = profiles(:dexter)
    @author = users(:jane)
    @reader = users(:john)

    set_session_current_user @author
  end

  test "should show profile subscribers" do
    get :index, :profile_name => @profile.to_param
    assert_equal Set.new([profiles(:dexter)]),
                 Set.new(assigns(:profiles))
    assert_response :success
  end

  test "should show repository subscribers" do
    get :index, :repo_name => @repository.to_param,
                :profile_name => @repository.profile.to_param
    assert_equal Set.new([profiles(:dexter), profiles(:costan)]),
                 Set.new(assigns(:profiles))
    assert_response :success
  end
  
  test "should create profile subscription" do
    set_session_current_user @reader
    assert_difference 'FeedItem.count' do
      assert_difference '@profile.subscribers(true).count' do
        post :create, :profile_name => @profile.to_param
      end
    end
    assert_redirected_to profile_url(@profile)
  
    assert @profile.subscribers.include?(@reader.profile), 'Not subscribed'
    item = FeedItem.last
    assert_equal 'subscribe', item.verb
    assert_equal @reader.profile, item.author
    assert_equal @profile, item.target
  end

  test "should create repository subscription" do
    set_session_current_user @reader
    @repository = repositories(:costan_ghost)
    assert_difference 'FeedItem.count' do
      assert_difference '@repository.subscribers(true).count' do
        post :create, :repo_name => @repository.to_param,
                      :profile_name => @repository.profile.to_param
      end
    end
    assert_redirected_to profile_repository_url(@repository.profile,
                                                @repository)

    assert @repository.subscribers.include?(@reader.profile), 'Not subscribed'
    item = FeedItem.last
    assert_equal 'subscribe', item.verb
    assert_equal @reader.profile, item.author
    assert_equal @repository, item.target
  end
  
  test "should remove profile subscription" do
    assert_difference 'FeedItem.count' do
      assert_difference '@profile.subscribers(true).count', -1 do
        delete :destroy, :profile_name => @repository.profile.to_param
      end
    end
    assert_redirected_to profile_url(@profile)

    item = FeedItem.last
    assert_equal 'unsubscribe', item.verb
    assert_equal @author.profile, item.author
    assert_equal @profile, item.target
  end

  test "should remove repository subscription" do
    assert_difference 'FeedItem.count' do
      assert_difference '@repository.subscribers(true).count', -1 do
        delete :destroy, :repo_name => @repository.to_param,
                         :profile_name => @repository.profile.to_param
      end
    end
    assert_redirected_to profile_repository_url(@repository.profile,
                                                @repository)

    item = FeedItem.last
    assert_equal 'unsubscribe', item.verb
    assert_equal @author.profile, item.author
    assert_equal @repository, item.target
  end
  
  test "should deny access to guests" do
    set_session_current_user nil
    get :index, :repo_name => @repository.to_param,
                :profile_name => @repository.profile.to_param
    assert_response :forbidden
    
    assert_no_difference 'FeedItem.count' do
      assert_no_difference '@repository.subscribers.count' do
        post :create, :repo_name => @repository.to_param,
                      :profile_name => @repository.profile.to_param
      end
    end
    assert_response :forbidden

    assert_no_difference 'FeedItem.count' do
      assert_no_difference '@repository.subscribers.count' do
        delete :destroy, :repo_name => @repository.to_param,
                         :profile_name => @repository.profile.to_param
      end
    end
    assert_response :forbidden
  end

  test 'routing' do
    assert_routing({:path => '/_/profiles/costan/subscribers', :method => :get},
                   {:controller => 'feed_subscriptions', :action => 'index',
                    :profile_name => 'costan'})
    assert_routing({:path => '/_/profiles/costan/subscribers',
                    :method => :post},
                   {:controller => 'feed_subscriptions', :action => 'create',
                    :profile_name => 'costan'})
    assert_routing({:path => '/_/profiles/costan/subscribers',
                    :method => :delete},
                   {:controller => 'feed_subscriptions', :action => 'destroy',
                    :profile_name => 'costan'})
                    
    assert_routing({:path => '/costan/rails/subscribers', :method => :get},
                   {:controller => 'feed_subscriptions', :action => 'index',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails/subscribers', :method => :post},
                   {:controller => 'feed_subscriptions', :action => 'create',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails/subscribers', :method => :delete},
                   {:controller => 'feed_subscriptions', :action => 'destroy',
                    :profile_name => 'costan', :repo_name => 'rails'})
  end
end
