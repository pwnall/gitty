module AclEntriesHelper
  def form_for_acl_entry(entry, *args, &block)
    case entry.subject
    when Repository
      form_for [entry.subject.profile, entry.subject, entry], *args, &block
    when Profile
      form_for [entry.subject, entry], *args, &block
    else
      raise "Unimplemented ACL subject class for #{entry.subject}"
    end
  end
  
  def acl_entries_path(subject)
    case entry.subject
    when Repository
      profile_repository_acl_entries_path(subject.profile, subject)
    when Profile
      profile_acl_entries_path(subject)
    end
  end
  
  def acl_entry_path(entry)
    case entry.subject
    when Repository
      profile_repository_acl_entry_path(entry.subject.profile, entry.subject, entry)
    when Profile
      profile_acl_entry_path(entry.subject, entry)
    else  
      raise "Unimplemented ACL subject class for #{entry.subject}"
    end
  end
end
