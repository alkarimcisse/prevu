Rails.application.routes.draw do
  get 'welcome/minor'

  devise_for :users
  resources :structure_aperitrices

  resources :micro_assurances
  resources :mutuelles
  resources :pharmacies
  resources :formation_sanitaires
  resources :adherents

  scope '/wservices' do
    post '/groupes' => 'ws#get_groupes'
    post '/adherent' => 'ws#adherent_infos'
  end

  devise_scope :user do
    match '/sessions/user', to: 'devise/sessions#create', via: :post
  end

  get "/log_out" => "sessions#destroy", :as => "log_out"
  get "/log_in" => "sessions#new", :as => "log_in"
  get "/sign_up" => "adherents#new", :as => "sign_up"

  resources :adherents do
    get '/affiliers' => 'adherents#affiliers', :as => 'affiliers'
    get '/add_affiliation' => 'adherents#new_parrainage', :as => 'new_parrainage'
    get '/edit_affiliation' => 'adherents#edit_parrainage', :as => 'edit_parrainage'
    member do
      post 'activate'
      post 'desactivate'
    end
  end
  resources :users, path: '/custom/users'
  resources :sessions

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
