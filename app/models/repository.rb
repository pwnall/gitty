# Git repository hosted on this server.
class Repository < ActiveRecord::Base
  # The profile representing the repository's author.
  belongs_to :profile
  validates :profile, :presence => true
  
  # The repository name.
  validates :name, :length => 1..64, :format => /\A\w+\Z/, :presence => true,
                   :uniqueness => { :scope => :profile_id }

  # The repository's location on disk.
  def local_path
    self.class.local_path profile.name, name
  end
  
  # The on-disk location of a repository.
  #
  # Args:
  #   profile_name:: the name of the profile owning the repository
  #   name:: the repository's name
  def self.local_path(profile_name, name)
    File.join '/home', ConfigFlag['git_user'], 'repos', profile_name,
              name + '.git'
  end
  
  # The repository's URL for SSH access.
  def ssh_uri
    ssh_root = "#{ConfigFlag['git_user']}@#{ConfigFlag['ssh_host']}" 
    "#{ssh_root}:#{profile.name}/#{name}.git"
  end
    
  # The Grit::Repo object for this repository.
  def grit_repo
    @grit_repo ||= !(new_record? || destroyed?) && Grit::Repo.new(local_path)
  end
end


# :nodoc: keep on-disk repositories synchronized
class Repository
  after_create :create_local_repository
  before_save :save_old_repository_name
  after_update :relocate_local_repository
  after_destroy :delete_local_repository

  # Creates a Git repository on disk.
  def create_local_repository
    # TODO: background job.
    @grit_repo = Grit::Repo.init_bare local_path
    FileUtils.chmod_R 0770, local_path
    
    @grit_repo
  end
  
  # Relocates a Git repository on disk.
  def self.relocate_local_repository(profile_name, old_name, new_name)
    # TODO: maybe this should be a background job.
    old_path = local_path profile_name, old_name
    new_path = local_path profile_name, new_name
    FileUtils.mv old_path, new_path
  end
  
  # Saves the repository's old name, so it can be relocated.
  def save_old_repository_name
    @_old_repository_name = name_change.first
  end
  
  # Relocates the on-disk repository after the model's name is changed.
  def relocate_local_repository
    old_name = @_old_repository_name    
    
    return if name == old_name
    self.class.relocate_local_repository profile.name, old_name, name
    @grit_repo = nil
  end    
  
  # Deletes the on-disk repository. 
  def delete_local_repository
    # TODO: background job.    
    FileUtils.rm_r local_path
    @grit_repo = nil
  end
end
