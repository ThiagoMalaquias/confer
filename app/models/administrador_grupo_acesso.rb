class AdministradorGrupoAcesso < ApplicationRecord
  belongs_to :administrador
  belongs_to :grupo_acesso
end
