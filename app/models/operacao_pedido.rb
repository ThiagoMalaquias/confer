class OperacaoPedido < ApplicationRecord
  belongs_to :operacao
  belongs_to :administrador
  has_many :operacao_pedido_itens, dependent: :destroy
  accepts_nested_attributes_for :operacao_pedido_itens, allow_destroy: true
end