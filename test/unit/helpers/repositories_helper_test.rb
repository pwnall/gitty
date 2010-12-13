require 'test_helper'

class RepositoriesHelperTest < ActionView::TestCase
  setup do
    @repository = repositories(:dexter_ghost)
  end

  test 'link_to_repository' do
    golden = '<a href="/dexter">dexter</a>/<a href="/dexter/ghost">ghost</a>'
    assert_equal golden, link_to_repository(@repository)    
  end
end
