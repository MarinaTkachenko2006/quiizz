# config/routes.rb
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount ActionCable.server => "/cable"

  root "welcome#index"

  get "register", to: "users#new"
  post "register", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "profile", to: "users#show", as: :profile
  get "profile/edit", to: "users#edit", as: :edit_profile
  patch "profile", to: "users#update"
  get "profile/change_password", to: "users#change_password", as: :change_password_profile
  patch "profile/update_password", to: "users#update_password", as: :update_password_profile

  resources :quizzes, only: [:new, :create, :index, :show, :destroy]

  get 'my_quizzes', to: 'my_quizzes#index'
end