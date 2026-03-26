class OperacaoPedidoItensController < ApplicationController
  before_action :set_operacao_pedido_item, only: [:show, :edit, :update, :destroy]

  def index
    @operacao_pedido_itens = OperacaoPedidoItem.all
  end

  def destroy
    @operacao_pedido_item.destroy
    respond_to do |format|
      format.html { redirect_to operacao_pedidos_url, notice: "Item do pedido deletado com sucesso." }
      format.json { head :no_content }
    end
  end

  private

  def set_operacao_pedido_item
    @operacao_pedido_item = OperacaoPedidoItem.find(params[:id])
  end
end