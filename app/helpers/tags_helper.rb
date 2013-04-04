module TagsHelper
  # A control that lets the user jump to a tag in a repository.
  def tag_switcher(repository, current_tag, label_text = 'Switch tag')
    content_tag 'div', class: 'dropdown' do
      content_tag('p', label_text) + content_tag('ul') {
        repository.tags.map { |tag|
          content_tag 'li' do
            link_to tag.name,
                profile_repository_tag_path(repository.profile, repository, tag)
          end
        }.join.html_safe
      }
    end
  end    
end
