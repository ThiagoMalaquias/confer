json.extract! operacao, :id, :qtd, :numero, :pedido_venda, :observacao, :created_at, :updated_at
json.url operacao_url(operacao, format: :json)
