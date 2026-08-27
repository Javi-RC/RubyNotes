Rails.application.routes.draw do
  resources :collections
  resources :notes

  resources :friends, only: %i[index new] do
    member do
      delete :remove
    end
  end

  post "send_request/:id", to: "friends#send_request", as: "send_request"
  get "show_profile/:id", to: "users#show_profile", as: "show_profile"
  get "see_friend/:id", to: "users#see_friend", as: "see_friend"

  # No :create — notifications are only ever raised by the app itself
  # (friend requests, shares). The exposed endpoint let a caller forge one.
  resources :notifications, only: %i[index update destroy] do
    member do
      post :accept
      post :deny
    end
  end

  resources :users do
    resources :notes, only: [:new]
    resources :collections, only: [:new]
  end

  resources :sessions, only: %i[new create destroy]
  resources :notes_owned, only: [:index]
  resources :collections_owned, only: [:index]

  get "home", to: "home#index"
  get "/up", to: "rails/health#show", as: :rails_health_check

  # /delete_account pointed at users#delete_account, which does not exist, so
  # it raised on every call. Account deletion goes through users#destroy,
  # which is what the profile page already uses.
  delete "/logout", to: "sessions#destroy", as: "logout"

  root "welcome#index"
end
