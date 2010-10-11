# A single blob (file) change in a commit. 
class CommitDiff < ActiveRecord::Base
  # The commit that this change is a part of.
  belongs_to :commit
  validates :commit, :presence => true
  
  # Changed path in the old commit tree. Nil for newly added blobs.
  #
  # This also differs from new_path for renames.
  validates :old_path,
      :length => { :in => 1..1.kilobyte, :allow_nil => true },
      :uniqueness => { :scope => :commit_id, :allow_nil => true }

  # Changed path in the new commit tree. Nil for removed blobs.
  #
  # This also differs from old_path for renames. 
  validates :new_path,
      :length => { :in => 1..1.kilobyte, :allow_nil => true },
      :uniqueness => { :scope => :commit_id, :allow_nil => true }

  # The blob contents before the commit. Nil for newly added blobs.
  belongs_to :old_blob, :class_name => 'Blob'
  validates :old_blob, :presence => true, :if => lambda { |d| d.old_path }
  
  # The blob contents after the commit. Nil for removed blobs.
  belongs_to :new_blob, :class_name => 'Blob'
  validates :new_blob, :presence => true, :if => lambda { |d| d.new_path }
  
  # Hunks in the diff.
  has_many :hunks, :class_name => 'CommitDiffHunk', :foreign_key => 'diff_id'
end
