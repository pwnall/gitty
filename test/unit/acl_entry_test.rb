require 'test_helper'

class AclEntryTest < ActiveSupport::TestCase
  setup do
    @john = users(:john)
    @jane = users(:jane)
    @acl_entry = AclEntry.new :principal => @jane, 
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
    assert_equal :edit, AclEntry.get(@jane, @jane.profile)
  end

  test 'set' do
    AclEntry.set @acl_entry.principal, @acl_entry.subject, :charge
    assert_equal :charge, AclEntry.get(@acl_entry.principal, @acl_entry.subject) 
    
    AclEntry.set(@jane, @jane.profile, :charge)
    assert_equal :charge, AclEntry.get(@jane, @jane.profile)
    
    AclEntry.set(@jane, @jane.profile, nil)
    assert_equal nil, AclEntry.get(@jane, @jane.profile)
  end
  
  test 'principal_name' do
    assert_equal @jane.email, @acl_entry.principal_name
  end
    
  test 'set principal_name before principal_type on new record' do
    entry = AclEntry.new :principal_name => @jane.name
    entry.principal_type = @jane.class.name
    assert_equal @jane.id, entry.principal_id
    assert_equal @jane, entry.principal
  end
  test 'set principal_type before principal_name on new record' do
    entry = AclEntry.new :principal_type => @jane.class.name
    entry.principal_name = @jane.name
    assert_equal @jane.id, entry.principal_id
    assert_equal @jane, entry.principal
  end
  test 'set principal_name after empty principal_type' do
    entry = AclEntry.new :principal_type => ''
    entry.principal_name = @jane.name
    assert_equal @jane.name, entry.principal_name
    assert_nil entry.principal_id
    assert_nil entry.principal
  end
  test 'set principal_name on existing record' do
    entry = acl_entries(:john_csail)
    entry.principal_name = @jane.name
    assert_equal @jane.id, entry.principal_id
    assert_equal @jane, entry.principal
  end
  test 'set principal_name before principal_type on existing record' do
    entry = acl_entries(:john_csail)
    entry.principal_name = @jane.name
    entry.principal_type = @jane.class.name
    assert_equal @jane.id, entry.principal_id
    assert_equal @jane, entry.principal
  end
  test 'set principal_type before principal_name on existing record' do
    entry = acl_entries(:john_csail)
    entry.principal_type = @jane.class.name
    entry.principal_name = @jane.name
    assert_equal @jane.id, entry.principal_id
    assert_equal @jane, entry.principal
  end
  
  test 'for' do
    assert_equal nil, AclEntry.for(@acl_entry.principal, @acl_entry.subject)
    
    entry = acl_entries(:john_csail)
    assert_equal entry, AclEntry.for(entry.principal, entry.subject)
  end
end
