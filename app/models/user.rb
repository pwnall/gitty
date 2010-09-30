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
  
  has_many :acl_entries, :as => :principal, :dependent => :destroy
  
  # All the profiles such that profile.can_charge? returns true for this user.
  def chargeable_profiles
    acl_entries.find(:role => "charge")
  end
end
