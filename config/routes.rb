Rails.application.routes.draw do
  root 'static_pages#index'

  resources :updates, only: [:index]

  resources :deletes, only: [:index]
 end
