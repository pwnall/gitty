# An user account.
class User < ActiveRecord::Base
  include Authpwn::UserModel

  # Virtual email attribute, with validation.
  include Authpwn::UserExtensions::EmailField
  # Virtual password attribute, with confirmation validation.
  include Authpwn::UserExtensions::PasswordField

  # Allow logging in by profile name.
  def self.authenticate_signin(signin)
    unless signin.email.index ?@
      if profile = Profile.where(name: signin.email).first
        signin = Session.new email: profile.user.email,
                             password: signin.password
      end
    end
    super signin
  end

  # Add your extensions to the User class here.

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
    user && user.admin?
  end

  # Flag set for site administrators.
  validates :admin, inclusion: { in: [true, false], allow_nil: false }

  # The profile representing this user.
  belongs_to :profile, inverse_of: :user

  # The repositories created by this user.
  has_many :repositories, through: :profile

  # The SSH keys used to authenticate this user.
  has_many :ssh_keys, dependent: :destroy, inverse_of: :user

  # Entries for profiles that this user has bits for.
  has_many :acl_entries, as: :principal, dependent: :destroy,
                         inverse_of: :principal

  # Aliases e-mail, to conform to the ACL principal interface.
  def name
    email
  end
  def self.find_by_name(name)
    if user = self.with_email(name)
      return user
    end
    (profile = Profile.find_by_name(name)) && profile.user
  end

  # All the profiles such that profile.can_charge? returns true for this user.
  def chargeable_profiles
    acl_entries.where(role: [:charge, :edit]).map(&:subject)
  end

  # All the profiles with an ACL entry for this user.
  def profiles
    acl_entries.map(&:subject)
  end

  # Profiles for the teams that this user is a member of, with any privilege.
  def team_profiles
    profiles.reject { |p| p == profile }
  end

  # All the repositories that this user can access, through a team.
  def team_repositories
    team_profiles.map(&:repositories).flatten
  end

  # Don't log in users with un-verified e-mails.
  def auth_bounce_reason(credential)
    (credential.is_a?(Credentials::Email) && !credential.verified?) ?
        :blocked : nil
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
