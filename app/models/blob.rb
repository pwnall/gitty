# Blob (file) in a git repository hosted on this server.
class Blob < ActiveRecord::Base
  # The repository that this blob is a part of.
  belongs_to :repository
  validates :repository, :presence => true

  # The git object id (sha of the object's data).
  validates :gitid, :length => 1..64, :presence => true,
                    :uniqueness => { :scope => :repository_id }  

  # Blob model for an on-disk blob (file).
  #
  # Args:
  #   git_blob:: a Grit::Blob object
  #   repository:: the Repository that this blob will belong to
  #
  # Returns an unsaved Blob model. It needs to be saved before child links to it
  # are created by calling TreeEntry#from_git_tree.
  def self.from_git_blob(git_blob, repository)
    self.new :repository => repository, :gitid => git_blob.id
  end
end
