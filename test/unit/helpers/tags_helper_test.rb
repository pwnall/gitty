require 'test_helper'

class TagsHelperTest < ActionView::TestCase
  setup do
    @repository = repositories(:dexter_ghost)
    @tag = tags(:unicorns)
  end
  
  test 'tag_switcher with no tag branch' do
    render text: tag_switcher(@repository, nil)
    
    assert_select 'div[class="dropdown"]' do
      assert_select 'ul' do
        assert_select 'li' do
          assert_select 'a[href="/dexter/ghost/tag/v1.0"]', 'v1.0'
          assert_select 'a[href="/dexter/ghost/tag/unicorns"]', 'unicorns'
          assert_select 'a[href="/dexter/ghost/tag/ci_request"]', 'ci_request'
        end
      end
    end
  end
  
  test 'tag_switcher with tag and preset label' do
    render text: tag_switcher(@repository, @tag, 'Other text')

    assert_select 'div[class="dropdown"]' do
      assert_select 'p', 'Other text'
      assert_select 'ul' do
        assert_select 'li' do
          assert_select 'a[href="/dexter/ghost/tag/v1.0"]', 'v1.0'
          assert_select 'a[href="/dexter/ghost/tag/unicorns"]', 'unicorns'
          assert_select 'a[href="/dexter/ghost/tag/ci_request"]', 'ci_request'
        end
      end
    end
  end  
end
