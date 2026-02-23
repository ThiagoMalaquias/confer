class OperacaoPedidosController < ApplicationController
  before_action :set_operacao_pedido, only: [:show, :edit, :update]

  def index
    @operacoes = Operacao.select(:id, :numero, :status).order(created_at: :desc)

    if params[:numero].present?
      @operacoes = @operacoes.where("numero = ?", params[:numero].to_s.strip)
    end

    if params[:data_inicio].present? && params[:data_fim].present?
      @operacoes = @operacoes.periodo_data(params[:data_inicio], params[:data_fim])
    end

    if params[:status].present?
      @operacoes = @operacoes.where(status: params[:status])
    end

    options = { page: params[:page] || 1, per_page: 32 }
    @operacoes = @operacoes.paginate(options)
  end

  def gerar_pedido
    @operacao = Operacao.find(params[:id_operacao])
    @operacao_pedido = OperacaoPedido.find_or_initialize_by(operacao_id: @operacao.id)
    @operacao_pedido.administrador_id = @current_user.id
    @operacao_pedido.save!
  end

  def show
  end

  def new
    @operacao_pedido = OperacaoPedido.new
  end

  def create
    @operacao_pedido = OperacaoPedido.new(operacao_pedido_params)
    if @operacao_pedido.save
      redirect_to operacao_pedidos_url, notice: 'Pedido criado com sucesso'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @operacao_pedido.update(operacao_pedido_params)
      redirect_to operacao_pedidos_url, notice: 'Pedido atualizado com sucesso'
    else
      render :edit
    end
  end  

  private

  def set_operacao_pedido
    @operacao_pedido = OperacaoPedido.find(params[:id])
  end

  def operacao_pedido_params
    params.require(:operacao_pedido).permit(
      :operacao_id, :administrador_id, :codigo, :status, :observacao, :erros,
      operacao_pedido_itens_attributes: [:id, :codigo, :descricao, :lote, :vencimento, :fabricacao, :prazo, :_destroy]
    )
  end
end