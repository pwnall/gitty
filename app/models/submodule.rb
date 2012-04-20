# Link to a Git repository whose content is included in this repository's tree.
class Submodule < ActiveRecord::Base
  include GitObjectModel
  
  # The repository that uses this submodule.
  belongs_to :repository, :inverse_of => :submodules
  validates :repository, :presence => true
  
  # The submodule name, used to look it up in the root's .git_submodules file.
  validates :name, :presence => true, :length => 1..128
  
  # The SHA-1 of the referenced repository's commit that will be checked out. 
  validates :gitid, :length => 1..64, :presence => true,
                    :uniqueness => { :scope => [:repository_id, :name] }

  # Submodule for an on-disk submodule reference.
  #
  # Args:
  #   git_submodule:: a Grit::Submodule object
  #   repository:: the Repository that this submodule will belong to
  #
  # Returns an unsaved Submodule model. It needs to be saved before child links
  # to it are created by calling TreeEntry#from_git_tree.
  def self.from_git_submodule(git_submodule, repository)
    self.new :repository => repository, :gitid => git_submodule.id,
             :name => git_submodule.basename
  end
end

# :nodoc: implement the Blob interface to match git's diff output
class Submodule
  # The contents of the file stored in the blob.
  def data
    @data ||= "Subproject commit #{gitid}\n".freeze
  end

  # The contents of the file stored in the blob, broken up into lines.  
  def data_lines
    @data_lines ||= ["Subproject commit #{gitid}".freeze].freeze
  end
  
  # The number of lines in the file stored in the blob.
  def data_line_count
    1
  end
end
