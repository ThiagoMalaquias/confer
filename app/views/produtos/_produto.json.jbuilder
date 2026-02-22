json.extract! produto, :id, :codigo, :ean, :descricao, :unc, :created_at, :updated_at
json.url produto_url(produto, format: :json)
