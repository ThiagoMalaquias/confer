class OperacoesController < ApplicationController
  before_action :set_operacao, only: [:show, :edit, :update, :destroy, :desbloquear]

  def index
    @operacoes = Operacao.order(created_at: :desc)
  
    if params[:pedido_venda].present?
      @operacoes = @operacoes.where(pedido_venda: params[:pedido_venda].to_s.strip)
    end
  
    if params[:data_inicio].present?
      inicio = Date.parse(params[:data_inicio]) rescue nil
      @operacoes = @operacoes.where("DATE(operacoes.created_at) >= ?", inicio) if inicio
    end
  
    if params[:data_fim].present?
      fim = Date.parse(params[:data_fim]) rescue nil
      @operacoes = @operacoes.where("DATE(operacoes.created_at) <= ?", fim) if fim
    end
  
    options = { page: params[:page] || 1, per_page: 10 }
    @operacoes = @operacoes.paginate(options)
  end

  def desbloquear
    @operacao.update(status: "PENDENTE", mensagem_erro: nil)
    @operacao.operacao_pedidos.first.update(erros: nil, status: "PENDENTE")
    redirect_to operacao_url(@operacao), notice: 'Operação desbloqueada com sucesso'
  end

  def show
  end

  def new
    @operacao = Operacao.new
  end

  def create
    @operacao = Operacao.new(operacao_params)
    if @operacao.save
      redirect_to operacoes_url, notice: 'Operação criada com sucesso'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @operacao.update(operacao_params)
      redirect_to operacoes_url, notice: 'Operação atualizada com sucesso'
    else
      render :edit
    end
  end

  def destroy
    @operacao.destroy
    redirect_to operacoes_url, notice: 'Operação deletada com sucesso'
  end

  private

  def set_operacao
    @operacao = Operacao.find(params[:id])
  end

  def operacao_params
    params.require(:operacao).permit(:qtd, :numero, :pedido_venda, :observacao,
      operacao_itens_attributes: [:id, :descricao, :qtd, :_destroy])
  end
end