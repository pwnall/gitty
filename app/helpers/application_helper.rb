module ApplicationHelper
  def link_to_gitty(object)
    case object
    when Profile
      link_to_profile object
    when Repository
      link_to_repository object
    when Branch
      link_to_branch object
    else
      raise "Unsupported type #{object.class.name}"
    end
  end
end
