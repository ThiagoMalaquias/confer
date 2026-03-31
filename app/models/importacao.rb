class Importacao < ApplicationRecord
  validates :relatorio, presence: true
  validates :tipo, presence: true

  before_update :verificar_status, if: :status_changed?

  enum tipo: {
    produto: 'produto',
    operacao: 'operacao'
  }

  private

  def verificar_status
   return if status != "PENDENTE"

   self.erros = nil 
  end
end
