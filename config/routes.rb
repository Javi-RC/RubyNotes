Rails.application.routes.draw do
  
  # Recursos principales
  resources :collections
  resources :notes
  resources :users do
    
    resources :notes, only: [:new]
    resources :collections, only: [:new]

  end
  
  resources :friends , only: [:index, :new] do
    delete 'remove', on: :member
  end
  get 'send_request/:id', to: 'friends#send_request', as: 'send_request'

  # Recursos secundarios

  get 'show_profile/:id', to: 'users#show_profile', as: 'show_profile'
  get 'see_friend/:id', to: 'users#see_friend', as: 'see_friend'

  # Acciones personalizadas para notificaciones
    resources :notifications , only: [:index, :update, :destroy]
  get 'notifications/:id/accept', to: 'notifications#accept', as: 'accept_notification'
  get 'notifications/:id/deny', to: 'notifications#deny', as: 'deny_notification'
  delete '/notifications/:id', to: 'notifications#destroy', as: 'delete_notification'

  # Rutas de sesión
  resources :sessions, only: [:new, :create, :destroy]

  # Rutas personalizadas para notas y colecciones propias
  resources :notes_owned, only: [:index]
  resources :collections_owned, only: [:index]

  # Otras rutas...
  
  # Rutas de inicio y salud
  get 'home', to: 'home#index'
  get '/up', to: 'rails/health#show', as: :rails_health_check

  # Ruta de eliminación de cuenta
  delete '/delete_account', to: 'users#delete_account', as: 'delete_account'

  # Ruta de cierre de sesión
  delete '/logout', to: 'sessions#destroy', as: 'logout'

  # Ruta de inicio
  root 'welcome#index'

  
end
