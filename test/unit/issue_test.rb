require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:costan_ghost)
    @issue = Issue.new :repository => @repo, :author => profiles(:dexter),
        :open => true, :title => 'Crashes on OSX',
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
  
  test 'users can edit their own issues' do
    assert @issue.can_edit?(users(:jane))
  end
  
  test "users can edit their repositories' issues" do
    assert @issue.can_edit?(users(:john))
  end

  test "users can't edit random issues" do
    assert !@issue.can_edit?(users(:rms))
  end
  
  test "non logged-in users can't edit issues" do
    assert !@issue.can_edit?(nil)
  end

  # TODO(christy13): publishing tests
end
