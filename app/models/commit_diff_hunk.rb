# A continuous block of lines (hunk) in a diff between two blob versions.
class CommitDiffHunk < ActiveRecord::Base
  # The diff that this hunk is a part of. 
  belongs_to :diff, :class_name => 'CommitDiff'
  validates :diff, :presence => true
  
  # The first line in the file's old (pre-change) version.
  validates :old_start, :numericality => { :greater_than_or_equal_to => 0 },
                        :presence => true

  # The size (in lines) in file's the old (pre-change) version.
  validates :old_count, :numericality => { :greater_than_or_equal_to => 0 },
                        :presence => true

  # The first line in the file's new (post-change) version.
  validates :new_start, :numericality => { :greater_than_or_equal_to => 0 },
                        :presence => true,
                        :uniqueness => { :scope => [:diff_id, :old_start] }

  # The size (in lines) in file's the new (post-change) version.
  validates :new_count, :numericality => { :greater_than_or_equal_to => 0 },
                        :presence => true

  # The patch context (first line with no blank spaces preceding the patch).
  #
  # This can be nil if the patch lines aren't indented.
  validates :context, :length => { :maximum => 1.kilobyte, :allow_nil => true }

  # A compressed version of the patch text produced by git's diff algorithm.
  #
  # Summaries are produced by calling CommitDiffHunk#patch_summary and they are
  # de-compressed in the patch_lines implementation.
  #
  # For large and complex patches, this field will be set to nil. It's unlikely
  # that a human would be able to review such patches with a conventional UI.
  validates :summary, :presence => true, :length => 1..32.kilobytes
  
  # An array of parsed lines making up the hunk's patch.
  #
  # Each array element is itself an array with the following elements:
  #   * the line number in the old file (nil for a newly added line)
  #   * the line number in the new file (nil for a deleted line)
  #   * the line contents in the old file
  #   * the line contents in the new file
  def patch_lines
    return @patch_lines if @patch_lines
    
    old_line, new_line = old_start, new_start
    
    old_lines = diff.old_blob && diff.old_blob.data_lines
    new_lines = diff.new_blob && diff.new_blob.data_lines
    
    diff_data = summary.split /(\d+)/
    lines = []
    i = 0
    while i < diff_data.length
      line_type, line_count = diff_data[i][0], diff_data[i + 1].to_i
      i += 2
      line_count.times do
        case line_type
        when ?+
          line = [nil, new_line, nil, nil]
          new_line += 1
        when ?-
          line = [old_line, nil, nil, nil]
          old_line += 1
        else
          line = [old_line, new_line, nil, nil]
          old_line += 1
          new_line += 1
        end
        line[2] = line[0] && old_lines[line[0] - 1]
        line[3] = line[1] && new_lines[line[1] - 1]
        lines << line
      end
    end
    @patch_lines = lines
  end
  
  # The diff hunks that make up a diff.
  #
  # Args:
  #   git_diff:: a Grit::Commit::Diff object
  #   diff:: the CommitDiff model corresponding to the Grit::Commit::Diff object
  #
  # Returns an array of unsaved CommitDiffHunk objects.
  def self.from_git_diff(git_diff, diff)
    diffs = {}    
    git_diff.hunks.map do |git_hunk|
      old_start = git_hunk.a_first_line || 0
      old_count = git_hunk.a_lines
      old_count ||= diff.old_blob ? diff.old_blob.data_line_count : 0      
      new_start = git_hunk.b_first_line || 0
      new_count = git_hunk.b_lines
      new_count ||= diff.new_blob ? diff.new_blob.data_line_count : 0
      context = git_hunk.context.blank? ? nil : git_hunk.context
      
      hunk = self.new :diff => diff, :old_start => old_start,
          :new_start => new_start, :old_count => old_count,
          :new_count => new_count, :context => context,
          :summary => patch_summary(git_hunk.diff)
    end
  end
  
  # Computes a summary of a hunk patch.
  #
  # Args:
  #   patch_text:: the output of Grit::Commit::Diff::Hunk#diff
  #
  # Returns a compressed representation of the patch. It can be used to retrieve
  # the patch, together with the two blobs involved in the diff.
  def self.patch_summary(patch_text)
    # Line types are sufficient to get line numbers. These can be used to get
    # the rest of the patch lines from the blobs involved in the diff.
    line_types = patch_text.split("\n").map { |line| line[0] }
    
    # Slightly-modified RLE compression.
    rle = []
    i = 0
    while line_types[i]
      j = 1
      while line_types[i + j] == line_types[i]
        j += 1
      end
      rle << line_types[i].chr
      rle << j
      i += j
    end
    rle.join
  end
end
