class Repository < ActiveRecord::Base
  # The repository name.
  validates :name, :length => 1..64, :format => /\A\w+\Z/, :presence => true,
                   :uniqueness => true

  # The repository's location on disk.
  def local_path
    File.join 'home', ConfigFlag['git_user'], name + ".git"
  end
  
  # The repository's URL for SSH access.
  def ssh_uri
    "#{ConfigFlag['git_user']}@#{request.host}:/#{name}"
  end
  
  # Creates the Git repository on disk.
  def create_local_repository
    @grit_repo = Grit::Repo.init_bare local_path
  end
  
  # The Grit::Repo object for this repository.
  def grit_repo
    @grit_repo ||= Grit::Repo.new local_path
  end
end
