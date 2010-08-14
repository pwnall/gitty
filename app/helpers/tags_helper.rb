module TagsHelper
  # A control that lets the user jump to a tag in a repository.
  def tag_switcher(repository, current_tag, label_text = 'Switch tag')
    form_tag profile_repository_tag_url(repository.profile,
                                        repository, 'name'),
             :method => :get do
      label_tag(:name, label_text) + ' ' +
      select_tag(:name, options_for_select(repository.tags.map(&:name),
          current_tag && current_tag.name))
    end
  end    
end
