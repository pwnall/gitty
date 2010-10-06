module AclEntriesHelper
  def acl_entry_roles(entry_class)
    if entry_class == Repository
      [
        [:read, 'Reader'],
        [:commit, 'Committer'],
        [:edit, 'Administrator']
      ]
    elsif entry_class == Profile
      [
        [:participate, 'Contributor'],
        [:charge, 'Billing'],
        [:edit, 'Administrator']
      ]
    else  
      raise "Unimplemented ACL subject class #{entry_class}"
    end      
  end
  
  def form_for_acl_entry(entry, &block)
    case entry.subject
    when Repository
      form_for [entry.subject.profile, entry.subject, entry], &block
    when Profile
      form_for [entry.subject, entry], &block
    else
      raise "Unimplemented ACL subject class for #{entry.subject}"
    end
  end
  
  def acl_entry_path(entry)
    case entry.subject
    when Repository
      profile_acl_entry_path(entry.subject.profile, entry.subject, entry)
    when Profile
      profile_acl_entry_path(entry.subject, entry)
    else  
      raise "Unimplemented ACL subject class for #{entry.subject}"
    end
  end
end
