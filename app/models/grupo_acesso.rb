class GrupoAcesso < ApplicationRecord
  has_many :administrador_grupo_acessos, :dependent => :delete_all

  after_save :save_administradores
  
  def acessos_parse
    acessos.present? ? JSON.parse(acessos) : []
  rescue
    []
  end
  
  def acessos_actions
    acessos_parse.pluck("acesso")
  rescue
    []
  end
  
  def acessos_views
    acessos_parse.pluck("acesso").uniq.compact.flatten
  rescue
    []
  end
  
  def administradores=(value)
    @administradores_ids = value
  end

  def administradores
    return @administradores if @administradores.present?

    @administradores = administrador_grupo_acessos.map { |ad| ad.administrador.id }
    @administradores
  end

  private

  def save_administradores
    if @administradores_ids.present?
      AdministradorGrupoAcesso.where(grupo_acesso_id: id).find_each(&:destroy)
      @administradores_ids.each do |administrador_id|
        adm = AdministradorGrupoAcesso.new
        adm.administrador_id = administrador_id
        adm.grupo_acesso_id = id
        adm.save!
      end
    end
  end
end
