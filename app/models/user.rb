# An user account.
class User < ActiveRecord::Base
  pwnauth_user_model

  # True if the given user can edit this user account.
  def can_edit?(user)
    self == user
  end
  
  # True if the given user can see this user account.
  def can_read?(user)
    self == user
  end
  
  # True if the given user can list the user account database.
  def self.can_list_users?(user)
    false
  end
  
  # Add your extensions to the User class here.

  belongs_to :profile
  
  # The repositories accessible to this user.
  has_many :repositories, :through => :profile
  
  # The SSH keys used to authenticate this user.
  has_many :ssh_keys, :dependent => :destroy
  
  # Entries for profiles that this user has bits for.
  has_many :acl_entries, :as => :principal, :dependent => :destroy
  
  # Aliases e-mail, to conform to the ACL principal interface.
  def name
    email
  end
  def self.find_by_name(name)
    find_by_email name
  end

  # All the profiles such that profile.can_charge? returns true for this user.
  def chargeable_profiles
    acl_entries.where(:role => [:charge, :edit]).map(&:subject)
  end
end


# :nodoc: set up an ACL entry for the profile's user
class User
  before_save :save_old_profile
  after_save :add_acl_entry
  
  # Saves the user's current profile for the post-save ACL fixup.
  def save_old_profile
    @_old_profile_id = profile_id_change ? profile_id_change.first : false
    true
  end
  
  # Creates an ACL entry for the user's profile.
  def add_acl_entry
    return if @_old_profile_id == false
    
    old_profile = @_old_profile_id && Profile.find(@_old_profile_id)
    AclEntry.set self, old_profile, nil if old_profile
    AclEntry.set self, profile, :edit if profile
  end
end
