require 'test_helper'

class FeedSubscriptionTest < ActiveSupport::TestCase
  setup do
    @profile = profiles(:mit)
    @repo = repositories(:dexter_ghost)
    @subscription = FeedSubscription.new :profile => @profile, :topic => @repo
  end
  
  test 'setup' do
    assert @subscription.valid?
  end
  
  test 'profile must be set' do
    @subscription.profile = nil
    assert !@subscription.valid?
  end
  
  test 'topic must be set' do
    @subscription.topic = nil
    assert !@subscription.valid?
  end
  
  test 'profile-topic must be unique' do
    @subscription.profile = profiles(:dexter)
    assert !@subscription.valid?
  end

  test 'subscribe to new topic' do
    assert !@profile.topics.include?(@repo), 'Broken assumption on fixtures'
    assert_equal [], @profile.topics, 'Broken assumption on fixtures'
    subscription = FeedSubscription.add @profile, @repo
    assert_equal @profile, subscription.profile
    assert_equal @repo, subscription.topic
    assert @profile.topics(true).include?(@repo), 'Subscription not added'
  end

  test 'subscribe to already-subscribed topic' do
    subscription = FeedSubscription.add profiles(:dexter), @repo
    assert_equal profiles(:dexter), subscription.profile
    assert_equal @repo, subscription.topic
    assert_equal false, subscription.new_record?
  end

  test 'unsubscribe from non-subscribed topic' do
    assert_equal [], @profile.topics, 'Broken assumption on fixtures'
    FeedSubscription.remove @profile, @repo
    assert_equal [], @profile.topics(true)
  end

  test 'unsubscribe from subscribed topic' do
    assert profiles(:dexter).topics.include?(@repo),
           'Broken assumption on fixtures'
    FeedSubscription.remove profiles(:dexter), @repo    
    assert !profiles(:dexter).topics(true).include?(@repo),
           'Subscription not removed'
  end
end
