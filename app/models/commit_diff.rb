# A single blob (file) change in a commit.
class CommitDiff < ActiveRecord::Base
  # The commit that this change is a part of.
  belongs_to :commit
  validates :commit, presence: true

  # Changed path in the old commit tree. Nil for newly added blobs.
  #
  # This also differs from new_path for renames.
  validates :old_path, length: { in: 1..1.kilobyte, allow_nil: true },
      uniqueness: { scope: :commit_id, allow_nil: true }

  # Changed path in the new commit tree. Nil for removed blobs.
  #
  # This also differs from old_path for renames.
  validates :new_path, length: { in: 1..1.kilobyte, allow_nil: true },
      uniqueness: { scope: :commit_id, allow_nil: true }

  # Blob contents or submodule before the commit. Nil for newly added objects.
  belongs_to :old_object, polymorphic: true
  validates :old_object, presence: true, :if => lambda { |diff| diff.old_path }

  # Blob contents after the commit. Nil for removed blobs and all submodules.
  belongs_to :new_object, polymorphic: true
  validates :new_object, presence: true, :if => lambda { |diff| diff.new_path }

  # Hunks in the diff.
  has_many :hunks, class_name: 'CommitDiffHunk', foreign_key: 'diff_id',
           dependent: :destroy

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
    old_commit = commit.parents.first
    git_commit.diffs.each do |git_diff|
      old_object = old_commit &&
          resolve_object(git_diff.a_blob, git_diff.a_path, old_commit)
      new_object = resolve_object git_diff.b_blob, git_diff.b_path, commit
      next unless old_object or new_object

      old_path = old_object && git_diff.a_path
      new_path = new_object && git_diff.b_path

      diff = self.new commit: commit, old_path: old_path, new_path: new_path,
                      old_object: old_object, new_object: new_object
      diffs[diff] = CommitDiffHunk.from_git_diff(git_diff, diff)
    end
    diffs
  end

  # Locates one of the two objects connected by a diff.
  #
  # Args:
  #  git_blob:: the Grit::Blob pointed to by the diff
  #  path:: the object path
  #  commit:: Commit instance for the commit that has the object
  #
  # Returns the object pointed by the diff (a Blob or Submodule).
  def self.resolve_object(git_blob, diff_path, commit)
    return nil unless git_blob

    blob = commit.repository.blobs.where(gitid: git_blob.id).first
    return blob if blob

    # This slow path is only activated for modules.
    diff_path.blank? ? nil : commit.tree.walk_path(diff_path)
  end
end
