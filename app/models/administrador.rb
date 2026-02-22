class Administrador < ApplicationRecord
  validates :nome, :email, :senha, presence: true
  has_many :administrador_grupo_acessos, dependent: :destroy
  
  def is_admin?
    return @is_admin if @is_admin.present?

    group_adm = AdministradorGrupoAcesso.where(administrador_id: id)
    @is_admin = group_adm.map { |g| g.grupo_acesso.nome.downcase }.include?("admin")
    @is_admin
  end

  def acessos
    return @acessos if @acessos.present?

    acessos = administrador_grupo_acessos.map { |ad| ad.grupo_acesso.acessos_actions }
    @acessos = []
    acessos.each do |a|
      @acessos += a
    end
    @acessos
  end

  def acessos_include?(permissao)
    acessos.each do |acesso|
      return true if acesso.include?(permissao)
    end

    return false
  end
end
