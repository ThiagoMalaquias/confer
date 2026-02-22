class OperacaoPedidosController < ApplicationController
  before_action :set_operacao_pedido, only: [:show, :edit, :update]

  def index
    @operacao_pedidos = OperacaoPedido.all
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
    params.require(:operacao_pedido).permit(:operacao_id, :administrador_id, :codigo, :status, :observacao, :erros)
  end
end