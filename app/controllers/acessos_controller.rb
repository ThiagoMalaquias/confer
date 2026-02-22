class AcessosController < ApplicationController
  before_action :set_acesso, only: %i[show edit update destroy]

  def index
    @acessos = Acesso.all
  end

  def show; end

  def new
    @acesso = Acesso.new
  end

  def edit; end

  def create
    @acesso = Acesso.new(acesso_params)

    respond_to do |format|
      if @acesso.save
        format.html { redirect_to @acesso, notice: 'Acesso criado com sucesso.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @acesso.update(acesso_params)
        format.html { redirect_to @acesso, notice: 'Acesso atuallizado com sucesso.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @acesso.destroy
    respond_to do |format|
      format.html { redirect_to acessos_url, notice: 'Acesso excuido com sucesso.' }
    end
  end

  private

  def set_acesso
    @acesso = Acesso.find(params[:id] || params[:acesso_id])
  end

  def acesso_params
    params.require(:acesso).permit(:nome, :menu_id)
  end
end
