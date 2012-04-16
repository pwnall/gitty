require 'test_helper'

class IssuesHelperTest < ActionView::TestCase
  test "readable open issues" do
    readable_issues = readable_open_issues([issues(:public_ghost_pizza), 
        issues(:public_ghost_dead_code), issues(:public_ghost_code_language),
        issues(:public_ghost_jquery)], users(:costan))
    assert_equal [issues(:public_ghost_dead_code)], readable_issues
    
    readable_issues = readable_open_issues([issues(:public_ghost_pizza), 
        issues(:public_ghost_dead_code), issues(:public_ghost_code_language),
        issues(:public_ghost_jquery)], users(:rms))
    assert_equal [issues(:public_ghost_pizza), 
        issues(:public_ghost_dead_code)].sort, readable_issues.sort
  end
  
  test "readable closed issues" do
    readable_issues = readable_closed_issues([issues(:public_ghost_pizza), 
        issues(:public_ghost_dead_code), issues(:public_ghost_code_language),
        issues(:public_ghost_jquery)], users(:costan))
    assert_equal [issues(:public_ghost_jquery)], readable_issues
    
    readable_issues = readable_closed_issues([issues(:public_ghost_pizza), 
        issues(:public_ghost_dead_code), issues(:public_ghost_code_language),
        issues(:public_ghost_jquery)], users(:rms))
    assert_equal [issues(:public_ghost_jquery), 
        issues(:public_ghost_code_language)].sort, readable_issues.sort
  end
end
