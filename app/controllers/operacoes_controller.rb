class OperacoesController < ApplicationController
  before_action :set_operacao, only: [:show, :edit, :update, :destroy, :desbloquear, :cancelar]

  def index
    @operacoes = Operacao.all
  
    if params[:pedido_venda].present?
      @operacoes = @operacoes.where(pedido_venda: params[:pedido_venda].to_s.strip)
    end

    if params[:status].present?
      @operacoes = @operacoes.where(status: params[:status])
    end
  
    if params[:data_inicio].present?
      inicio = Date.parse(params[:data_inicio]) rescue nil
      @operacoes = @operacoes.where("DATE(operacoes.created_at) >= ?", inicio) if inicio
    end
  
    if params[:data_fim].present?
      fim = Date.parse(params[:data_fim]) rescue nil
      @operacoes = @operacoes.where("DATE(operacoes.created_at) <= ?", fim) if fim
    end

    sort = params[:sort].presence_in(%w[pedido_venda qtd itens_qtd status observacao created_at]) || "pedido_venda"
    direction = params[:direction].presence_in(%w[asc desc]) || "asc"
    sort_sql = if sort == "itens_qtd"
                 "(SELECT COALESCE(SUM(operacao_itens.qtd), 0) FROM operacao_itens WHERE operacao_itens.operacao_id = operacoes.id)"
               else
                 "operacoes.#{sort}"
               end
               
    @operacoes = @operacoes.order(Arel.sql("#{sort_sql} #{direction}"))
  
    options = { page: params[:page] || 1, per_page: 10 }
    @operacoes = @operacoes.paginate(options)
  end

  def desbloquear
    @operacao.update(status: "PENDENTE", mensagem_erro: nil)
    @operacao.operacao_pedidos.first.update(erros: nil, status: "PENDENTE")
    redirect_to operacao_url(@operacao), notice: 'OP desbloqueada com sucesso'
  end

  def cancelar
    @operacao.update(status: "PENDENTE")
    @operacao.operacao_pedidos.first.update(erros: nil, status: "PENDENTE")
    @operacao.operacao_pedidos.first.operacao_pedido_itens.destroy_all
    email_operacao_cancelada
    redirect_to operacao_url(@operacao), notice: 'OP cancelada com sucesso'
  end

  def show
  end

  def new
    @operacao = Operacao.new
  end

  def create
    @operacao = Operacao.new(operacao_params)
    if @operacao.save
      redirect_to operacoes_url, notice: 'OP criada com sucesso'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @operacao.update(operacao_params)
      redirect_to operacoes_url, notice: 'OP atualizada com sucesso'
    else
      render :edit
    end
  end

  def destroy
    email_operacao_excluida

    @operacao.destroy
    redirect_to operacoes_url, notice: 'OP excluída com sucesso'
  end

  private

  def email_operacao_cancelada
    emails.each do |email|
      EmailsMailer.operacao_cancelada(@operacao, email).deliver
    end
  end

  def email_operacao_excluida
    emails.each do |email|
      EmailsMailer.operacao_excluida(@operacao, email).deliver
    end
  end

  def emails
    ["tammalaquias@gmail.com", "supervisor.mg@capitaldascestas.com.br", "comprasmg@capitaldascestas.com.br", "com163@capitaldascestas.com.br", "diretoriamg@capitaldascestas.com.br", "logistica1.mg@capitaldascestas.com.br"]
  end

  def set_operacao
    @operacao = Operacao.find(params[:id])
  end

  def operacao_params
    params.require(:operacao).permit(:qtd, :numero, :pedido_venda, :observacao,
      operacao_itens_attributes: [:id, :descricao, :qtd, :_destroy])
  end
end