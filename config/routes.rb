Gitty::Application.routes.draw do

  scope '_' do
    authpwn_session
    config_vars

    resources :ssh_keys

    # Users.
    get '/users' => 'users#index', as: :users
    post '/users' => 'users#create'
    get '/users/register' => 'users#new', as: :new_user
    get '/user/:user_param(.:format)' => 'users#show', as: :user,
        constraints: { user_param: /[^\/]+/ }
    get '/user/:user_param/edit(.:format)' => 'users#edit', as: :edit_user,
        constraints: { user_param: /[^\/]+/ }
    put '/user/:user_param(.:format)' => 'users#update',
        constraints: { user_param: /[^\/]+/ }
    delete '/user/:user_param(.:format)' => 'users#destroy',
           constraints: { user_param: /[^\/]+/ }
  end

  scope '_' do
    get 'check_access.:format' => 'repositories#check_access',
        as: :repository_check_access
    post 'change_notice.:format' => 'repositories#change_notice',
         as: :repository_change_notice
  end

  # Profiles.
  get '/:profile_name(.:format)' => 'profiles#show', as: :profile,
      constraints: { profile_name: /[^_][^\/]+/ }
  put '/:profile_name(.:format)' => 'profiles#update',
      constraints: { profile_name: /[^_][^\/]+/ }
  delete '/:profile_name(.:format)' => 'profiles#destroy',
         constraints: { profile_name: /[^_][^\/]+/ }
  scope '_' do
    resources :profiles, only: [:index, :new, :create]
    scope 'profiles' do
      get ':profile_name(.:format)' => 'profiles#show'
      get ':profile_name/edit(.:format)' => 'profiles#edit', as: :edit_profile
      put ':profile_name(.:format)' => 'profiles#update'
      delete ':profile_name(.:format)' => 'profiles#destroy'
    end
  end

  scope ':profile_name', constraints: { profile_name: /[^_][^\/]+/ } do
    # Mis-used git-over http repository link.
    get ':repo_name.git' => 'smart_http#index',
        constraints: { repo_name: /[^\/]+/ }, format: false, as: :git_over_http

    # Repositories.
    get ':repo_name(.:format)' => 'repositories#show',
        constraints: { repo_name: /[^\/]+/ }, as: :profile_repository
    put ':repo_name(.:format)' => 'repositories#update',
        constraints: { repo_name: /[^\/]+/ }
    delete ':repo_name(.:format)' => 'repositories#destroy',
           constraints: { repo_name: /[^\/]+/ }
    get ':repo_name/edit(.:format)' => 'repositories#edit',
        :constraints => { :repo_name => /[^\/]+/ },
        :as => :edit_profile_repository
  end
  scope '_' do
    resources :repositories, only: [:index, :new, :create]
    scope 'repositories/:profile_name' do
      get ':repo_name(.:format)' => 'repositories#show'
      get ':repo_name/edit(.:format)' => 'repositories#edit'
      put ':repo_name(.:format)' => 'repositories#update'
      delete ':repo_name(.:format)' => 'repositories#destroy'
    end
  end

  # HTTP fetch and push.
  scope ':profile_name/:repo_name.git', constraints: {
      profile_name: /[^_\/]+/, repo_name: /[^\/]+/ } do
    post 'git-upload-pack' => 'smart_http#upload_pack'
    post 'git-receive-pack' => 'smart_http#receive_pack'
    get 'info/refs' => 'smart_http#info_refs'
    get '*path' => 'smart_http#git_file', format: false
  end

  scope ':profile_name/:repo_name',
      constraints: { profile_name: /[^_\/]+/, repo_name: /[^\/]+/ } do
    # Feed.
    get 'subscribers(.:format)' => 'feed_subscriptions#index',
        as: :subscribers_profile_repository
    post 'subscribers(.:format)' => 'feed_subscriptions#create'
    delete 'subscribers(.:format)' => 'feed_subscriptions#destroy'
    get 'feed(.:format)' => 'repositories#feed', as: :feed_profile_repository

    # Commits.
    get 'commits(/:ref_name)' => 'commits#index',
        as: :profile_repository_commits, constraints: {ref_name: /[^\/]+/ }
    get 'commit/:commit_gid(.:format)' => 'commits#show',
        as: :profile_repository_commit

    # Branches.
    get 'branches' => 'branches#index', as: :profile_repository_branches
    get 'branch/:branch_name(.:format)' => 'branches#show',
        as: :profile_repository_branch

    # Tags.
    get 'tags' => 'tags#index', as: :profile_repository_tags
    get 'tag/:tag_name' => 'tags#show', as: :profile_repository_tag,
        constraints: {tag_name: /[^\/]+/}

    # Trees.
    scope 'tree/:commit_gid', constraints: { commit_gid: /[^\/]+/ } do
      get '*path' => 'trees#show', as: :profile_repository_tree
      get '/' => 'trees#show', as: :profile_repository_commit_tree
    end

    # Blobs.
    scope 'blob/:commit_gid', constraints: { commit_gid: /[^\/]+/ } do
      get '*path' => 'blobs#show', as: :profile_repository_blob, format: false
    end
    scope 'raw/:commit_gid', constraints: { commit_gid: /[^\/]+/ } do
      get '*path' => 'blobs#raw', as: :raw_profile_repository_blob,
                                  format: false
    end

    # Issues
    resources :issues, only: [:create]
    get 'issues' => 'issues#index', as: :profile_repository_issues
    get 'issues/new' => 'issues#new', as: :new_profile_repository_issue
    get 'issues/:issue_number' => 'issues#show', as: :profile_repository_issue
    get 'issues/:issue_number/edit(.:format)' => 'issues#edit',
        as: :edit_profile_repository_issue
    put 'issues/:issue_number' => 'issues#update'
    delete 'issues/:issue_number' => 'issues#destroy'

    # ACLs.
    get 'acl_entries' => 'acl_entries#index', as: :profile_repository_acl_entries
    post 'acl_entries' => 'acl_entries#create'
    put 'acl_entries/:principal_name' => 'acl_entries#update',
        as: :profile_repository_acl_entry,
        constraints: { principal_name: /[^_][^\/]+/ }
    delete 'acl_entries/:principal_name' => 'acl_entries#destroy',
        constraints: { principal_name: /[^_][^\/]+/ }
  end

  # Profile sub-resources. (must follow repository sub-resources)
  scope '_' do
    scope 'profiles/:profile_name',
          constraints: { profile_name: /[^_][^\/]+/ } do
      # ACLs.
      get 'acl_entries' => 'acl_entries#index', as: :profile_acl_entries
      post 'acl_entries' => 'acl_entries#create'
      put 'acl_entries/:principal_name' => 'acl_entries#update',
          as: :profile_acl_entry, constraints: { principal_name: /[^_][^\/]+/ }
      delete 'acl_entries/:principal_name' => 'acl_entries#destroy',
          constraints: { principal_name: /[^_][^\/]+/ }

      # Feed.
      get 'subscribers(.:format)' => 'feed_subscriptions#index',
          as: :subscribers_profile
      post 'subscribers(.:format)' => 'feed_subscriptions#create'
      delete 'subscribers(.:format)' => 'feed_subscriptions#destroy'
    end
  end

  root to: 'session#show'
end
