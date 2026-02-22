class OperacaoPedidoItem < ApplicationRecord
  belongs_to :operacao
  belongs_to :pedido
end
