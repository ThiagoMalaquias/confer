class Acesso < ApplicationRecord
  has_many :acessos_perfil_acesso, dependent: :destroy
  belongs_to :menu

  default_scope { order('nome asc') }
end
