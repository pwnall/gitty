# Methods common to all models that represent objects in Git repositories.
module GitObjectModel
  # An ID that git will still consider unique, but shorter than the full gitid.
  def short_gitid
    gitid[0, 8]
  end
end
