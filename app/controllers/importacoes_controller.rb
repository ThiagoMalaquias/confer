class ImportacoesController < ApplicationController
  before_action :set_importacao, only: [:show]

  def index
    @importacoes = Importacao.order(created_at: :desc)
    @importacoes = @importacoes.where(tipo: "operacao") if !@current_user.is_admin?

    options = { page: params[:page] || 1, per_page: 10 }
    @importacoes = @importacoes.paginate(options)
  end 

  def show
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

  private

  def set_importacao
    @importacao = Importacao.find(params[:id])
  end

  def importacao_params
    params.require(:importacao).permit(:tipo)
  end
end