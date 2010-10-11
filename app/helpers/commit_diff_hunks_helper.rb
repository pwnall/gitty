module CommitDiffHunksHelper
  def commit_patch_line_class(patch_line)
    if patch_line[0]
      if patch_line[1]
        'same'
      else
        'deleted'
      end
    else
      'added'
    end
  end
end
