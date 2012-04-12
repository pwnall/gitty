require 'test_helper'

class AclEntriesHelperTest < ActionView::TestCase
  test 'form_for_acl_entry for Repository' do
    entry = acl_entries(:csail_dexter_ghost)
    render :text => form_for_acl_entry(entry) { 'form body' }
  
    assert_select 'form[action="/dexter/ghost/acl_entries/csail"]', 'form body'
  end

  test 'form_for_acl_entry for Profile' do
    entry = acl_entries(:costan_csail)
    render :text => form_for_acl_entry(entry) { 'form body' }
  
    assert_select 'form[action="/_/profiles/csail/acl_entries/costan@gmail.com"]',
                  'form body'
  end
  
  test 'form_for_acl_entry raises error for User subject' do
    assert_raise RuntimeError do
      acl_entries(:csail_dexter_ghost).subject = users(:costan)
      form_for_acl_entry acl_entries(:csail_dexter_ghost) do
        # This should not be called.
      end
    end    
  end
  
  test 'acl_entries_path' do
    assert_equal '/_/profiles/dexter/acl_entries',
                 acl_entries_path(profiles(:dexter))
    assert_equal '/dexter/ghost/acl_entries',
                 acl_entries_path(repositories(:dexter_ghost))
    assert_raise RuntimeError do
      acl_entries_path users(:costan)
    end
  end
  
  test 'acl_entry_path' do
    assert_equal '/_/profiles/csail/acl_entries/costan@gmail.com',
                 acl_entry_path(acl_entries(:costan_csail))
    assert_equal '/dexter/ghost/acl_entries/csail',
                 acl_entry_path(acl_entries(:csail_dexter_ghost))
    
    assert_raise RuntimeError do
      acl_entries(:csail_dexter_ghost).subject = users(:costan)
      acl_entry_path acl_entries(:csail_dexter_ghost)
    end    
  end
end
