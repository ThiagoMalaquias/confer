require 'sidekiq/web'
Rails.application.routes.draw do
  # sidekiq server
  mount Sidekiq::Web => '/sidekiq'

  resources :operacoes
  resources :operacao_pedidos
  resources :operacao_pedido_itens
  resources :administradores
  resources :produtos
  resources :importacoes
  resources :grupo_acessos

  root to: 'home#index'

  resources :login do
    collection do
      post :sign_in
      get :sign_up
    end
  end
end
