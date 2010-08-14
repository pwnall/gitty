module BranchesHelper
  # A control that lets the user jump to a branch in a repository.
  def branch_switcher(repository, current_branch, label_text = 'Switch branch')
    form_tag profile_repository_branch_url(repository.profile,
                                           repository, 'name'),
             :method => :get do
      label_tag(:name, label_text) + ' ' +
      select_tag(:name, options_for_select(repository.branches.map(&:name),
          current_branch && current_branch.name))
    end 
  end
end
