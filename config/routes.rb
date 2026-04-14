Rails.application.routes.draw do
  resources :operacoes do
    get "desbloquear", on: :member, action: :desbloquear
    get "cancelar", on: :member, action: :cancelar
  end
  resources :operacao_pedido_itens
  resources :administradores
  resources :importacoes
  resources :grupo_acessos

  resources :operacao_pedidos do
    get "gerar_pedido/:id_operacao", on: :collection, action: :gerar_pedido
    post "validar_item", on: :collection, action: :validar_item
  end

  resources :produtos do
    collection do
      get :buscar
      get :buscar_por_ean
      get :gerar_excel
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
