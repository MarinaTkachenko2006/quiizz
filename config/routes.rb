Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "register", to: "users#new"
  post "register", to: "users#create"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :quizzes, only: [:new, :create, :index, :show, :destroy]
  resources :users, only: [:new, :create]

  get 'my_quizzes', to: 'my_quizzes#index'

  get "profile", to: "users#show", as: :profile
  get "profile/edit", to: "users#edit", as: :edit_profile
  patch "profile", to: "users#update"
  get "profile/change_password", to: "users#change_password", as: :change_password_profile
  patch "profile/update_password", to: "users#update_password", as: :update_password_profile

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  resources :quizzes, only: [:new, :create, :index, :show, :destroy]
  root "welcome#index"
end
