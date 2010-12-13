require 'test_helper'

class ProfilesHelperTest < ActionView::TestCase
  setup do
    @profile = profiles(:dexter)
  end

  test 'link_to_profile' do
    golden = '<a href="/dexter">dexter</a>'
    assert_equal golden, link_to_profile(@profile)    
  end
end
