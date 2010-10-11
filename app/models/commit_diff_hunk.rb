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

  # The text of the diff, in patch format.
  #
  # For large patches, this field will be set to nil. It's unlikely that a human
  # would be able to review the patches in a normal UI.
  validates :patch_text, :presence => true, :length => 1..1.megabyte
  
  # An array of parsed lines making up the hunk's patch.
  #
  # Each array element is itself an array with the following elements:
  #   * the line number in the old file (nil for a newly added line)
  #   * the line number in the new file (nil for a deleted line)
  #   * the line contents in the old file
  #   * the line contents in the new file
  def patch_lines
    lines = []
    old_line, new_line = old_start, new_start
    
    # TODO(costan): replace this stupidly naive algorithm with something more
    #               decent
    patch_text.split("\n").each do |line|
      case line[0]
      when ?+
        lines << [nil, new_line, nil, line]
        new_line += 1
      when ?-
        lines << [old_line, nil, line, nil]
        old_line += 1
      else
        lines << [old_line, new_line, line, line]
        old_line += 1
        new_line += 1
      end
    end
    lines
  end
end
