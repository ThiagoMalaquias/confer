class ImportacoesController < ApplicationController
  before_action :set_importacao, only: [:show, :edit, :update, :destroy]

  def index
    @importacoes = Importacao.order(created_at: :desc)
    @importacoes = @importacoes.where(tipo: "operacao") if !@current_user.is_admin?

    options = { page: params[:page] || 1, per_page: 10 }
    @importacoes = @importacoes.paginate(options)
  end 

  def show
  end

  def edit
  end

  def update
    @importacao.update(importacao_params)
    redirect_to importacao_url(@importacao), notice: 'Importação atualizada com sucesso'
  end

  def create
    @importacao = Importacao.new(importacao_params)
    @importacao.relatorio = AwsService.upload(params[:relatorio].tempfile.path, params[:relatorio].original_filename)
    if @importacao.save
      redirect_to importacoes_url, notice: 'Importação criada com sucesso. Em breve os dados serão importados.'
    else
      render :new
    end
  end
  
  def update
    @importacao.update(importacao_params)
    redirect_to importacao_url(@importacao), notice: 'Importação atualizada com sucesso'
  end
  
  def destroy
    @importacao.destroy
    redirect_to importacoes_url, notice: 'Importação deletada com sucesso'
  end

  private

  def set_importacao
    @importacao = Importacao.find(params[:id])
  end

  def importacao_params
    params.require(:importacao).permit(:status, :erros)
  end
end