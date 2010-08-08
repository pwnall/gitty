module ProfilesHelper
  def profile_select_options
    [current_user.profile].map { |p| [p.name, p.id] }
  end
end
