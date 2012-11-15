require 'test_helper'

class IssuesHelperTest < ActionView::TestCase
  setup do
    @repository = repositories(:public_ghost)
    @issues = @repository.issues
  end
  
  test "readable closed issues" do
    assert_equal [issues(:public_ghost_jquery)],
                 readable_closed_issues(@issues, users(:costan))
    
    assert_equal [issues(:public_ghost_jquery),
                  issues(:public_ghost_code_language)].sort,
                 readable_closed_issues(@issues, users(:rms)).sort
  end
  
  test "readable open issues" do
    assert_equal [issues(:public_ghost_dead_code)],
                 readable_open_issues(@issues, users(:costan))
    
    assert_equal [issues(:public_ghost_security_vulnerability),
                  issues(:public_ghost_pizza), 
                  issues(:public_ghost_dead_code)].sort,
                 readable_open_issues(@issues, users(:rms)).sort
  end
  
  test "open issue counter" do
    assert_equal '(3)', issue_counter(@repository, users(:rms))
    assert_equal '(1)', issue_counter(@repository, users(:costan))
    assert_equal '', issue_counter(Repository.new, users(:costan)) 
  end
end
