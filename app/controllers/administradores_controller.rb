class AdministradoresController < ApplicationController
  before_action :set_administrador, only: [:show, :edit, :update, :destroy]

  def index
    @administradores = Administrador.all

    options = { page: params[:page] || 1, per_page: 10 }
    @administradores = @administradores.paginate(options)
  end

  def show
  end

  def new
    @administrador = Administrador.new
  end

  def create
    @administrador = Administrador.new(administrador_params)
    if @administrador.save
      redirect_to administradores_url, notice: 'Usuário interno criado com sucesso'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @administrador.update(administrador_params)
      redirect_to administradores_url, notice: 'Usuário interno atualizado com sucesso'
    else
      render :edit
    end
  end

  def destroy
    @administrador.destroy
    redirect_to administradores_url, notice: 'Usuário interno deletado com sucesso'
  end

  private

  def set_administrador
    @administrador = Administrador.find(params[:id])
  end

  def administrador_params
    params.require(:administrador).permit(:nome, :email, :senha)
  end
end