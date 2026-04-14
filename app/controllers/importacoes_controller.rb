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
    arquivo = params[:relatorio]
  
    unless arquivo.present?
      flash[:error] = "Selecione um arquivo."
      redirect_to importacoes_url
      return
    end
  
    extensao_ok = File.extname(arquivo.original_filename.to_s).downcase == ".xlsx"
    mime_ok = [
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "application/octet-stream" 
    ].include?(arquivo.content_type)
  
    unless extensao_ok && mime_ok
      flash[:error] = "Arquivo inválido. Envie um arquivo .xlsx."
      redirect_to importacoes_url
      return
    end
  
    @importacao = Importacao.new(importacao_params)
    @importacao.relatorio = AwsService.upload(arquivo.tempfile.path, arquivo.original_filename)
  
    if @importacao.save
      redirect_to importacoes_url, notice: "Importação criada com sucesso. Em breve os dados serão importados."
    else
      flash[:error] = @importacao.errors.full_messages.join(", ")
      redirect_to importacoes_url
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
    params.require(:importacao).permit(:status, :erros, :tipo)
  end
end