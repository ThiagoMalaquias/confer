class Operacao < ApplicationRecord
  has_many :operacao_itens, dependent: :destroy
  accepts_nested_attributes_for :operacao_itens, allow_destroy: true
end