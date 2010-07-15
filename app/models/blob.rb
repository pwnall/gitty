# Blob (file) in a git repository hosted on this server.
class Blob < ActiveRecord::Base
  # The repository that this blob is a part of.
  belongs_to :repository
  validates :repository, :presence => true
end
