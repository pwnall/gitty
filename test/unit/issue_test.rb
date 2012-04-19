require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:costan_ghost)
    @issue = Issue.new :repository => @repo, :author => profiles(:dexter),
        :open => true, :sensitive => false, :title => 'Crashes on OSX',
        :description => 'Running Lion 10.7'
  end
  
  test 'setup' do
    assert @issue.valid?
  end
  
  test 'requires repository' do
    @issue.repository = nil
    assert !@issue.valid?
  end

  test 'requires author' do
    @issue.author = nil
    assert !@issue.valid?
  end

  test 'requires title' do
    @issue.title = nil
    assert !@issue.valid?
  end

  test 'requires non-empty title' do
    @issue.title = ''
    assert !@issue.valid?
  end

  test 'requires description' do
    @issue.description = nil
    assert !@issue.valid?
  end

  test 'accepts empty description' do
    @issue.description = ''
    assert @issue.valid?
  end

  test 'requires open' do
    @issue.open = nil
    assert !@issue.valid?
  end

  test 'accepts open=false' do
    @issue.open = false
    assert @issue.valid?
  end
  
  test 'requires sensitive' do
    @issue.sensitive = nil
    assert !@issue.valid?
  end
  
  test 'accepts sensitive=true' do
    @issue.sensitive = true
    assert @issue.valid?
  end
  
  test 'users can edit their own issues' do
    assert @issue.can_edit?(users(:dexter))
  end
  
  test "users can edit their repositories' issues" do
    assert @issue.can_edit?(users(:costan))
  end

  test "users can't edit random issues" do
    assert !@issue.can_edit?(users(:rms))
  end
  
  test "non logged-in users can't edit issues" do
    assert !@issue.can_edit?(nil)
  end
  
  test "can read issue if sensitive = false" do
    issue = issues(:public_ghost_dead_code)
    issue.sensitive = false
    assert issue.can_read?(users(:costan))
  end
  
  test "cannot read issue if sensitive = true" do
    issue = issues(:public_ghost_dead_code)
    issue.sensitive = true
    assert !issue.can_read?(users(:costan))
  end

  # Publishing tests
  test 'publish_open_issue from issue' do
    item = nil
    assert_difference 'FeedItem.count' do
      item = @issue.publish_opening
    end
    assert_equal @issue.author, item.author
    assert_equal 'open_issue', item.verb
    assert_equal @issue, item.target
    assert_equal 'Crashes on OSX', item.data[:issue_title]
  end
  
  test 'publish_close_issue from issue' do
    item = nil
    profile = profiles(:dexter)
    assert_difference 'FeedItem.count' do
      item = @issue.publish_closure(profile)
    end
    assert_equal @issue.author, item.author
    assert_equal 'close_issue', item.verb
    assert_equal @issue, item.target
    assert_equal 'ghost', item.data[:repo_name]
    assert_equal 'Crashes on OSX', item.data[:issue_title]
  end
  
  test 'publish_reopen_issue from issue' do
    item = nil
    profile = profiles(:dexter)
    assert_difference 'FeedItem.count' do
      item = @issue.publish_reopening(profile)
    end
    assert_equal @issue.author, item.author
    assert_equal 'reopen_issue', item.verb
    assert_equal @issue, item.target
    assert_equal 'ghost', item.data[:repo_name]
    assert_equal 'Crashes on OSX', item.data[:issue_title]
  end
  
  test 'should not publish_open_issue from issue if sensitive' do
    item = nil
    @issue.sensitive = true
    assert_no_difference 'FeedItem.count' do
      item = @issue.publish_opening
    end
    assert_nil item
  end
end