Gitty::Application.routes.draw do
  scope '/gitty' do
    resources :config_vars
  
    resource :session, :controller => 'session'
  
    resources :users
    
    resources :commits
  
    resources :branches
  
    resources :ssh_keys
  
    resources :repositories
    
    resources :trees, :only => :show
    
    resources :blobs, :only => :show
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:7
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  match '/gitty/check_access.:format' => 'repositories#check_access',
        :as => :repository_check_access
  match '/gitty/change_notice.:format' => 'repositories#change_notice',
        :as => :repository_change_notice
  
  # Profiles.
  scope 'gitty' do
    resources :profiles, :only => [:index, :new, :create]
  end
  get '/:profile_name(.:format)' => 'profiles#show', :as => :profile
  get '/gitty/profiles/:profile_name(.:format)' => 'profiles#show'
  get '/gitty/profiles/:profile_name/edit(.:format)' => 'profiles#edit',
      :as => :edit_profile
  put '/:profile_name(.:format)' => 'profiles#update'
  put '/gitty/profiles/:profile_name(.:format)' => 'profiles#update'
  delete '/:profile_name(.:format)' => 'profiles#destroy'
  delete '/gitty/profiles/:profile_name(.:format)' => 'profiles#destroy'

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "session#show"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
