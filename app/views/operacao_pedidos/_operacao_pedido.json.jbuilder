json.extract! operacao_pedido, :id, :operacao_id, :administrador_id, :codigo, :status, :observacao, :erros, :created_at, :updated_at
json.url operacao_pedido_url(operacao_pedido, format: :json)
