require 'test_helper'

class FeedItemTopicTest < ActiveSupport::TestCase
  setup do
    @feed_item_topic = FeedItemTopic.new :topic => profiles(:costan),
        :feed_item => feed_items(:dexter_creates_ghost)
  end
  
  test 'setup' do
    assert @feed_item_topic.valid?
  end
  
  test 'topic must be set' do
    @feed_item_topic.topic = nil
    assert !@feed_item_topic.valid?
  end
  
  test 'feed_item must be set' do
    @feed_item_topic.feed_item = nil
    assert !@feed_item_topic.valid?
  end
  
  test 'feed_item-topic must be unique' do
    @feed_item_topic.topic = profiles(:dexter)
    assert !@feed_item_topic.valid?
  end
end
