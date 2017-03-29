Rails.application.routes.draw do
  telegram_webhooks TelegramWebhooksController
  root to: 'auctions#index'

  devise_for :users
  resources :banned_users, only: [:index, :create, :destroy]
  resources :auctions do
    get :start, on: :member
    get :stop, on: :member
  end
end
