Rails.application.routes.draw do
  root to: 'auctions#index'

  devise_for :users
  resources :auctions
end
