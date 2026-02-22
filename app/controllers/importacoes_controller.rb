class ImportacoesController < ApplicationController
  def create
    @importacao = Importacao.new(importacao_params)
    if @importacao.save
      redirect_to importacoes_url, notice: 'Importação criada com sucesso'
    else
      render :new
    end
  end

  private

  def importacao_params
    params.require(:importacao).permit(:relatorio, :tipo, :status, :erros)
  end
end