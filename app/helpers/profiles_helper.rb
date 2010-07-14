module ProfilesHelper
  def profile_select_options
    Profile.all.map { |p| [p.name, p.id] }
  end
end
