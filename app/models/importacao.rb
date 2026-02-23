class Importacao < ApplicationRecord
  validates :relatorio, presence: true
  validates :tipo, presence: true

  enum tipo: {
    produto: 'produto',
    operacao: 'operacao'
  }
end
