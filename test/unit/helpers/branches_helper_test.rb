require 'test_helper'

class BranchesHelperTest < ActionView::TestCase
  setup do
    @repository = repositories(:dexter_ghost)
    @branch = branches(:branch1)
  end
  
  test 'branch_switcher with no current branch' do
    render :text => branch_switcher(@repository, nil)
    
    assert_select 'form[action="http://test.host/dexter/ghost/branch/name"][method="get"]' do
      assert_select 'select[name="name"]' do
        assert_select 'option[value="master"]', 'master'
        assert_select 'option[value="branch1"]', 'branch1'
        assert_select 'option[value="deleted"]', 'deleted'
      end
    end
  end
  
  test 'branch_switcher with branch and preset label' do
    render :text => branch_switcher(@repository, @branch, 'Other text')
    assert_select 'form[action="http://test.host/dexter/ghost/branch/name"][method="get"]' do
      assert_select 'label', 'Other text'
      assert_select 'select[name="name"]' do
        assert_select 'option[value="master"]', 'master'
        assert_select 'option[value="branch1"][selected="selected"]', 'branch1'
        assert_select 'option[value="deleted"]', 'deleted'
      end
    end
  end
end
