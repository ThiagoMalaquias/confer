class AdministradorGrupoAcessosController < ApplicationController
  before_action :set_administrador_grupo_acesso, only: %i[show edit update destroy]

  def index
    @administrador_grupo_acessos = AdministradorGrupoAcesso.all
  end

  def show; end

  def new
    @administrador_grupo_acesso = AdministradorGrupoAcesso.new
  end

  def edit; end

  def create
    @administrador_grupo_acesso = AdministradorGrupoAcesso.new(administrador_grupo_acesso_params)

    respond_to do |format|
      if @administrador_grupo_acesso.save
        format.html { redirect_to @administrador_grupo_acesso, notice: 'Administrador grupo acesso foi criado com sucesso.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @administrador_grupo_acesso.update(administrador_grupo_acesso_params)
        format.html { redirect_to @administrador_grupo_acesso, notice: 'Administrador grupo acesso foi atualizado com sucesso.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @administrador_grupo_acesso.destroy
    respond_to do |format|
      format.html { redirect_to administrador_grupo_acessos_url, notice: 'Administrador grupo acesso foi excluído com sucesso' }
      format.json { head :no_content }
    end
  end

  private

  def set_administrador_grupo_acesso
    @administrador_grupo_acesso = AdministradorGrupoAcesso.find(params[:id])
  end

  def administrador_grupo_acesso_params
    params.require(:administrador_grupo_acesso).permit(:administrador_id, :grupo_acesso_id)
  end
end
