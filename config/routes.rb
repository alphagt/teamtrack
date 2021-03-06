TeamTrack::Application.routes.draw do

  mount IAPI::Base, at: "/"

  resources :settings
  resources :initiatives do
  	get 'archive', :on => :member
  end
  
  resources :assignments do
  	#get 'new', :on => :member
  	get 'extend', :on => :member
  end

  resources :projects do
  	get 'archive', :on => :member
  	post 'import', :on => :collection
  end
  
  resources :tech_systems do
  	get 'archive', :on => :member

  end
  
  authenticated :user do
  	#root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users do
  	get 'index'
  	get 'verify'
  	get 'teamlist', :on => :collection
  	get 'reset', :on => :member
  	get 'manage', :on => :member
  	get 'team', :on => :member
  	get 'extendteam', :on => :member
  	get 'extendCurrentAssignment', :on => :member
  	post 'createemp', :on => :collection
  	post 'exit', :on => :member
  	put 'update_accts', :on => :member
  end 
  #match 'users/emp/create' => 'users#createemp', :as => :createemp
  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
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
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
