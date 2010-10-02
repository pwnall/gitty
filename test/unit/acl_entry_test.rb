require 'test_helper'

class AclEntryTest < ActiveSupport::TestCase
  setup do
    @acl_entry = AclEntry.new :principal => users(:john), 
                              :subject => profiles(:csail),
                              :role => 'member'
  end
  
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
