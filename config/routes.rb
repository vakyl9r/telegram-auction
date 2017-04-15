Rails.application.routes.draw do
  telegram_webhooks TelegramWebhooksController, as: :mywebhook
  root to: 'auctions#index'
  devise_for :users
  resources :banned_users, only: [:index, :create, :destroy]
  resources :channels, except: [:new, :show]
  resources :auctions do
    get :start, on: :member
    get :stop, on: :member
  end

  require 'sidekiq/web'
  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
end
