require 'sidekiq/web'
Rails.application.routes.draw do
  # sidekiq server
  mount Sidekiq::Web => '/sidekiq'

  root to: 'home#index'
end
