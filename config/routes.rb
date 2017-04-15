Rails.application.routes.draw do
  telegram_webhooks TelegramWebhooksController, as: :mywebhook
  root to: 'auctions#index'
  get "/telegram/338002994:AAF-g__IdKVhJoNoi3plNVfuKhQkgHQ7BgA", to: redirect ("/telegram/338002994_AAF-g__IdKVhJoNoi3plNVfuKhQkgHQ7BgA")
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
