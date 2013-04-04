require 'test_helper'

class FeedItemTest < ActiveSupport::TestCase
  setup do
    @item = FeedItem.new author: profiles(:dexter), verb: 'subscribe',
                         target: profiles(:mit), data: {test: :data}
  end
  
  test 'setup' do
    assert @item.valid?
  end
  
  test 'author must be set' do
    @item.author = nil
    assert !@item.valid?
  end

  test 'target must be set' do
    @item.target = nil
    assert !@item.valid?
  end

  test 'verb must be set' do
    @item.verb = nil
    assert !@item.valid?
  end
  
  test 'verb must belong to whitelist' do
    @item.verb = 'fail_me_please'
    assert !@item.valid?
  end
 
  test 'topics' do
    assert_equal Set.new([profiles(:dexter), repositories(:dexter_ghost)]),
        Set.new(feed_items(:dexter_creates_ghost).topics)
  end
  
  test 'data serialization' do
    @item.save!
    assert_equal @item.data, FeedItem.find(@item.id).data
  end
  
  test 'publish' do
    item = nil
    assert_difference 'FeedItem.count' do
      item = FeedItem.publish @item.author, @item.verb, @item.target,
          [@item.author, @item.target, @item.target], @item.data
    end
    assert_equal Set.new([@item.author, @item.target]), Set.new(item.topics)
    assert_equal @item.author, item.author
    assert_equal @item.verb, item.verb
    assert_equal @item.target, item.target
    assert_equal @item.data, item.data
  end
  
  test 'target_repository' do
    assert_equal repositories(:dexter_ghost),
                 feed_items(:dexter_creates_ghost).target_repository,
                 'target is a repository'
    assert_equal repositories(:dexter_ghost),
                 feed_items(:dexter_deletes_branch2).target_repository,
                 'dead branch with live repository'
    assert_equal repositories(:dexter_ghost),
                 feed_items(:dexter_creates_branch1).target_repository,
                 'live branch with live repository'
    assert_equal nil,
                 feed_items(:dexter_follows_mit).target_repository,
                 'no repository involved'
  end
  
  test 'target repository with fixture changes' do
    feed_items(:dexter_deletes_branch2).data[:repository_id] = 0
    assert_equal nil,
                 feed_items(:dexter_follows_mit).target_repository,
                 'dead branch with dead repository'
  end
end
