class Operacao < ApplicationRecord
  has_many :operacao_itens, dependent: :destroy
  accepts_nested_attributes_for :operacao_itens, allow_destroy: true

  scope :periodo_data, ->(data_inicio, data_fim) { where("TO_CHAR(operacoes.created_at - interval '3 hour','YYYY-MM-DD') >= ? and TO_CHAR(operacoes.created_at - interval '3 hour','YYYY-MM-DD') <= ?", data_inicio, data_fim) }
end