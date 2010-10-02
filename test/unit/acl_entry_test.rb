require 'test_helper'

class AclEntryTest < ActiveSupport::TestCase
  setup do
    @acl_entry = AclEntry.new :principal => users(:john), 
                              :subject => profiles(:csail),
                              :role => 'member'
  end
  
  test 'setup' do
    assert @acl_entry.valid?
  end
  
  test 'rejects entries without roles' do
    @acl_entry.role = nil
    assert !@acl_entry.valid?
  end
  
  test 'rejects entries with empty roles' do
    @acl_entry.role = ''
    assert !@acl_entry.valid?
  end
  
  test 'rejects entries without subjects' do
    @acl_entry.subject = nil
    assert !@acl_entry.valid?
  end

  test 'rejects entries without principals' do
    @acl_entry.principal = nil
    assert !@acl_entry.valid?
  end  
end
