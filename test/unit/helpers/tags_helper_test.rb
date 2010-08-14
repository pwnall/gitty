require 'test_helper'

class TagsHelperTest < ActionView::TestCase
  setup do
    @repository = repositories(:dexter_ghost)
    @tag = tags(:unicorns)
  end
  
  test 'tag_switcher with no tag branch' do
    render :text => tag_switcher(@repository, nil)
    
    assert_select 'form[action="http://test.host/dexter/ghost/tag/name"][method="get"]' do
      assert_select 'select[name="name"]' do
        assert_select 'option[value="v1.0"]', 'v1.0'
        assert_select 'option[value="unicorns"]', 'unicorns'
        assert_select 'option[value="ci_request"]', 'ci_request'
      end
    end
  end
  
  test 'tag_switcher with tag and preset label' do
    render :text => tag_switcher(@repository, @tag, 'Other text')

    assert_select 'form[action="http://test.host/dexter/ghost/tag/name"][method="get"]' do
      assert_select 'label', 'Other text'
      assert_select 'select[name="name"]' do
        assert_select 'option[value="v1.0"]', 'v1.0'
        assert_select 'option[value="unicorns"][selected="selected"]', 'unicorns'
        assert_select 'option[value="ci_request"]', 'ci_request'
      end
    end
  end  
end
