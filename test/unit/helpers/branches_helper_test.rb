require 'test_helper'

class BranchesHelperTest < ActionView::TestCase
  setup do
    @repository = repositories(:dexter_ghost)
    @branch = branches(:branch1)
  end
  
  test 'branch_switcher with no current branch' do
    render :text => branch_switcher(@repository, nil)
    
    assert_select 'div[class="dropdown"]' do
      assert_select 'ul' do
        assert_select 'li' do
          assert_select 'a[href="/dexter/ghost/branch/master"]', 'master'
          assert_select 'a[href="/dexter/ghost/branch/branch1"]', 'branch1'
          assert_select 'a[href="/dexter/ghost/branch/deleted"]', 'deleted'
        end
      end
    end
  end
  
  test 'branch_switcher with branch and preset label' do
    render :text => branch_switcher(@repository, @branch, 'Other text')
    assert_select 'div[class="dropdown"]' do
      assert_select 'p', 'Other text'
      assert_select 'ul' do
        assert_select 'li' do
          assert_select 'a[href="/dexter/ghost/branch/master"]', 'master'
          assert_select 'a[href="/dexter/ghost/branch/branch1"]', 'branch1'
          assert_select 'a[href="/dexter/ghost/branch/deleted"]', 'deleted'
        end
      end
    end
  end
end
