class OperacaoPedidosController < ApplicationController
  before_action :set_operacao_pedido, only: [:show, :edit, :update]
  skip_before_action :verify_authenticity_token, only: [:validar_item]

  def index
    @operacoes = Operacao.select(:id, :pedido_venda, :status).order(pedido_venda: :asc)

    if params[:pedido_venda].present?
      @operacoes = @operacoes.where("pedido_venda = ?", params[:pedido_venda].to_s.strip)
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

    OperacaoPedidos::PrefillItensSemValidacaoEanService.new(operacao_pedido: @operacao_pedido).call
  end

  def validar_item
    result = OperacaoPedidos::ValidarItemService.new(
      id_operacao: params[:id_operacao],
      params_operacao_pedido: params[:operacao_pedido],
      current_user: @current_user
    ).call
  
    render json: result.payload, status: result.status
  end

  def show
  end

  def new
    @operacao_pedido = OperacaoPedido.new
  end

  def create
    @operacao_pedido = OperacaoPedido.new(operacao_pedido_params)
    if @operacao_pedido.save
      redirect_to "/operacao_pedidos/gerar_pedido/#{@operacao_pedido.operacao_id}", notice: 'Pedido criado com sucesso'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @operacao_pedido.update(operacao_pedido_params)
      resultado = OperacaoPedidos::ValidarProdutosService.new(
        operacao_pedido: @operacao_pedido
      ).call
  
      unless resultado.ok?
        @operacao_pedido.operacao.update(status: "ERRO", mensagem_erro: "O operador da linha #{@current_user.nome} tentou Gerar OP, mas com divergências: #{resultado.errors.join(', ')}.")

        @operacao_pedido.update(
          status: "ERRO",
          erros: "#{(resultado.errors.join(', '))}"
        )
  
        redirect_to "/operacao_pedidos/gerar_pedido/#{@operacao_pedido.operacao_id}", alert: "Pedido salvo, mas com divergências. Verifique os itens do pedido."
        return
      end
  
      @operacao_pedido.update(status: "CONCLUIDO", erros: nil)
      @operacao_pedido.operacao.update(status: "CONCLUIDO", mensagem_erro: nil)
      email_operacao_concluida
      redirect_to "/operacao_pedidos/gerar_pedido/#{@operacao_pedido.operacao_id}", notice: "Pedido atualizado com sucesso"
    else
      render :edit
    end
  end

  private

  def set_operacao_pedido
    @operacao_pedido = OperacaoPedido.find(params[:id])
  end

  def email_operacao_concluida
    operacao = @operacao_pedido.operacao

    # emails = ["tammalaquias@gmail.com"]
    emails = ["tammalaquias@gmail.com", "supervisor.mg@capitaldascestas.com.br", "comprasmg@capitaldascestas.com.br", "com162@capitaldascestas.com.br", "diretoriamg@capitaldascestas.com.br"]
    emails.each do |email|
      EmailsMailer.operacao_concluida(operacao, email).deliver
    end
  end

  def operacao_pedido_params
    params.require(:operacao_pedido).permit(
      :operacao_id, :administrador_id, :codigo, :status, :observacao, :erros,
      operacao_pedido_itens_attributes: [:id, :codigo, :descricao, :lote, :vencimento, :fabricacao, :prazo, :_destroy]
    )
  end
end