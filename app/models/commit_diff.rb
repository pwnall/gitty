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
  has_many :hunks, :class_name => 'CommitDiffHunk', :foreign_key => 'diff_id',
           :dependent => :destroy

  # The diffs that make up a commit.
  #
  # Args:
  #   git_commit:: a Grit::Commit object
  #   commit:: the (saved) Commit model corresponding to the Grit::Commit object
  #
  # Returns a hash mapping unsaved CommitDiff objects to arrays of unsaved
  # CommitDiffHunk objects. The CommitDiff objects need to be saved before
  # the hunks can be saved.
  def self.from_git_commit(git_commit, commit)
    unless git_commit.id == commit.gitid
      raise ArgumentError, "commit doesn't correspond to git_commit"
    end
    
    diffs = {}    
    repo = commit.repository
    git_commit.diffs.each do |git_diff|
      old_blob = git_diff.a_blob &&
          repo.blobs.where(:gitid => git_diff.a_blob.id).first
      new_blob = git_diff.b_blob &&
          repo.blobs.where(:gitid => git_diff.b_blob.id).first
      old_path = old_blob && git_diff.a_path
      new_path = new_blob && git_diff.b_path
    
      diff = self.new :commit => commit, :old_path => old_path,
          :new_path => new_path, :old_blob => old_blob, :new_blob => new_blob
      diffs[diff] = CommitDiffHunk.from_git_diff(git_diff, diff)
    end
    diffs
  end
end
