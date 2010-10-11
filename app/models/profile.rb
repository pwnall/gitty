# The profile of an author (user or group) on the site.
class Profile < ActiveRecord::Base
  # The repositories created by this profile.
  has_many :repositories, :dependent => :destroy
  
  # This profile's ACL. All entries have Users as principals.
  has_many :user_acl_entries, :class_name => "AclEntry", :as => :subject, 
                              :dependent => :destroy

  # The repositories that have this profile on their ACLs.
  has_many :profile_acl_entries, :class_name => "AclEntry", :as => :principal, 
                                 :dependent => :destroy
  
  # The ACL entries shown in the ACL editing UI.
  def acl_entries
    user_acl_entries
  end
  
  # The profile's short name, used in URLs.
  validates :name, :length => 1..32, :format => /\A\w+\Z/, :presence => true,
                   :uniqueness => true
  
  # The profile's long name.
  validates :display_name, :length => 1..256, :presence => true
  
  # For profiles that represent users (not groups).
  has_one :user

  # The location of the profile's repositories on disk.
  def local_path
    self.class.local_path name
  end
    
  # Use the profile name instead of ID in all routes.
  def to_param
    name
  end
  
  # True if this is a team profile.
  def is_team_profile?
    user == nil
  end
  
  # The location of a profile's repositories on disk.
  #
  # Args:
  #   name:: the repository's name
  def self.local_path(name)
    File.join UserHomeDir.for(ConfigVar['git_user']), 'repos', name
  end  
end

# :nodoc: keep on-disk user directories synchronized
class Profile
  after_create :create_profile_directory
  before_save :save_old_profile_name
  after_update :relocate_profile_directory
  after_destroy :delete_profile_directory

  # Creates a directory for the user's repositories on disk.
  def create_profile_directory
    # TODO: background job.
    FileUtils.mkdir_p local_path
    FileUtils.chmod_R 0770, local_path
    begin
      FileUtils.chown_R ConfigVar['git_user'], nil, local_path
    rescue ArgumentError
      # Happens in unit testing, when the git user isn't created yet.
      raise unless Rails.env.test?
    rescue Errno::EPERM
      # Not root, not allowed to chown.    
    end    
    local_path
  end
  
  # Relocates a Git repository on disk.
  def self.relocate_profile_directory(old_name, new_name)
    # TODO: maybe this should be a background job.
    old_path = local_path old_name
    new_path = local_path new_name
    FileUtils.mv old_path, new_path
  end
  
  # Saves the profile's old name, so it can be relocated.
  def save_old_profile_name
    @_old_profile_name = name_change.first if name_change
  end
  
  # Relocates the profile's disk directory, after the model's name is changed.
  def relocate_profile_directory
    return unless old_name = @_old_profile_name
    
    return if name == old_name
    self.class.relocate_profile_directory old_name, name
  end
  
  # Deletes the on-disk repository. 
  def delete_profile_directory
    # TODO: background job.    
    FileUtils.rm_r local_path if File.exist? local_path
  end
end

# :nodoc: access control
class Profile
  def can_participate?(user)
    can_x? user, [:participate, :charge, :edit] 
  end
  
  # True if the user can charge repositories to this profile.
  def can_charge?(user)
    # NOTE: this will be replaced to support group profiles.
    can_x? user, [:charge, :edit]
  end
  
  # True if the user can edit the profile.
  def can_edit?(user)
    can_x? user, [:edit]
  end

  def can_x?(user, role)
    user && user_acl_entries.exists?(:principal_id => user.id, 
        :principal_type => user.class.name, :role => role)
  end
  private :can_x?

  # All the valid ACL roles when a Profile is the subject.   
  def self.acl_roles
    [
      ['Contributor', :participate],
      ['Billing', :charge],
      ['Administrator', :edit]
    ]
  end
  
  # Expected class of principals on ACL entries whose subjects are Profiles. 
  def self.acl_principal_class
    User
  end
end
