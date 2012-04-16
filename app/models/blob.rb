# Blob (file) in a git repository hosted on this server.
class Blob < ActiveRecord::Base
  include GitObjectModel
  
  # The repository that this blob is a part of.
  belongs_to :repository, :inverse_of => :blobs
  validates :repository, :presence => true

  # The git object id (sha of the object's data).
  validates :gitid, :length => 1..64, :presence => true,
                    :uniqueness => { :scope => :repository_id }  

  # The MIME type for the blob (helpful for generating a preview).
  validates :mime_type, :length => 1..256, :presence => true
  
  # The size of the data in the blob.
  validates :size, :presence => true,
      :numericality => { :integer_only => true, :greater_than_or_equal_to => 0}

  # Blob model for an on-disk blob (file).
  #
  # Args:
  #   git_blob:: a Grit::Blob object
  #   repository:: the Repository that this blob will belong to
  #
  # Returns an unsaved Blob model. It needs to be saved before child links to it
  # are created by calling TreeEntry#from_git_tree.
  def self.from_git_blob(git_blob, repository)
    self.new :repository => repository, :gitid => git_blob.id,
             :mime_type => git_blob.mime_type, :size => git_blob.size
  end
  
  # Use git SHAs instead of IDs.
  def to_param
    gitid
  end
  
  # The contents of the file stored in the blob.
  def data
    @data ||= repository.grit_repo.blob(gitid).data.freeze
  end

  # The contents of the file stored in the blob, broken up into lines.  
  def data_lines
    @data_lines ||= data.split("\n").freeze.each(&:freeze)
  end
  
  # The number of lines in the file stored in the blob.
  def data_line_count
    data_lines.count
  end
end
