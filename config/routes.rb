Rails.application.routes.draw do
  resources :collections
  resources :notes

  resources :friends, only: [:index, :new] do
    member do
      delete :remove
    end
  end

  post "send_request/:id", to: "friends#send_request", as: "send_request"
  get "show_profile/:id", to: "users#show_profile", as: "show_profile"
  get "see_friend/:id", to: "users#see_friend", as: "see_friend"

  resources :notifications, only: [:index, :update, :create, :destroy] do
    member do
      get :accept
      get :deny
    end
  end

  resources :users do
    resources :notes, only: [:new]
    resources :collections, only: [:new]
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :notes_owned, only: [:index]
  resources :collections_owned, only: [:index]

  get "home", to: "home#index"
  get "/up", to: "rails/health#show", as: :rails_health_check

  delete "/delete_account", to: "users#delete_account", as: "delete_account"
  delete "/logout", to: "sessions#destroy", as: "logout"

  root "welcome#index"
end
