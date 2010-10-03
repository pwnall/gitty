require 'test_helper'

class AclEntryTest < ActiveSupport::TestCase
  setup do
    @john = users(:john)
    @acl_entry = AclEntry.new :principal => @john, 
                              :subject => profiles(:csail),
                              :role => :participate
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
  
  test 'rejects duplicate entries' do
    @acl_entry.subject = @acl_entry.principal.profile
    assert !@acl_entry.valid?
  end

  test 'get' do
    assert_equal nil, AclEntry.get(@acl_entry.principal, @acl_entry.subject)
    assert_equal :edit, AclEntry.get(@john, @john.profile)
  end

  test 'set' do
    AclEntry.set @acl_entry.principal, @acl_entry.subject, :charge
    assert_equal :charge, AclEntry.get(@acl_entry.principal, @acl_entry.subject) 
    
    AclEntry.set(@john, @john.profile, :charge)
    assert_equal :charge, AclEntry.get(@john, @john.profile)
    
    AclEntry.set(@john, @john.profile, nil)
    assert_equal nil, AclEntry.get(@john, @john.profile)
  end
end
