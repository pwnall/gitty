# An user account.
class User < ActiveRecord::Base
  pwnauth_user_model

  # Add your extensions to the User class here.

  belongs_to :profile
  
  # The repositories accessible to this user.
  has_many :repositories, :through => :profile
  
  # The SSH keys used to authenticate this user.
  has_many :ssh_keys, :dependent => :destroy
  
  # All the profiles such that profile.can_charge? returns true for this user.
  def chargeable_profiles
    profile ? [profile] : []
  end
end
