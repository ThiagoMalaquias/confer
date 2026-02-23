Rails.application.routes.draw do
  resources :operacoes
  resources :operacao_pedido_itens
  resources :administradores
  resources :importacoes
  resources :grupo_acessos

  resources :operacao_pedidos do
    get "gerar_pedido/:id_operacao", on: :collection, action: :gerar_pedido
  end

  resources :produtos do
    collection do
      get :buscar
      get :buscar_por_ean
    end
  end

  root to: 'home#index'

  resources :login do
    collection do
      post :sign_in
      get :sign_up
    end
  end
end
