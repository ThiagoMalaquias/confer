class OperacaoPedidos::ValidarItemService
  Result = Struct.new(:success?, :status, :payload, keyword_init: true)

  def initialize(id_operacao:, params_operacao_pedido:, current_user:)
    @id_operacao = id_operacao
    @params_operacao_pedido = params_operacao_pedido || {}
    @current_user = current_user
  end

  def call
    operacao = Operacao.find(@id_operacao)
    operacao_itens = operacao.operacao_itens
    operacao_pedido = operacao.operacao_pedidos.first
    operacao_pedido_itens = operacao_pedido.operacao_pedido_itens

    ean = @params_operacao_pedido[:ean].to_s.strip
    produto = Produto.find_by(ean: ean)

    if produto.nil?
      msg_operacao = "O operador da linha #{@current_user.nome} tentou adicionar o EAN #{ean} porém o produto não foi encontrado."
      msg_pedido = "O EAN #{ean} do produto não foi encontrado."

      operacao.update(mensagem_erro: msg_operacao, status: "ERRO")
      operacao_pedido.update(erros: msg_pedido, status: "ERRO")

      return failure(status: :not_found, error: "Produto não encontrado")
    end

    unless operacao_itens.where("descricao ilike ?", "%#{produto.codigo}%").exists?
      msg_operacao = "O operador da linha #{@current_user.nome} tentou adicionar o produto #{produto.descricao} porém o produto não foi encontrado na operação."
      msg_pedido = "O produto #{produto.descricao} não foi encontrado na operação."

      operacao.update(mensagem_erro: msg_operacao, status: "ERRO")
      operacao_pedido.update(erros: msg_pedido, status: "ERRO")

      return failure(status: :unprocessable_entity, error: "Produto não encontrado na operação")
    end

    qtd_itens_pedido = operacao_pedido_itens.where(codigo: produto.codigo).count
    qtd_itens_operacao = operacao_itens.where("descricao ilike ?", "%#{produto.codigo}%").last&.qtd || 1

    if qtd_itens_operacao == qtd_itens_pedido
      msg_operacao = "O operador da linha #{@current_user.nome} tentou adicionar o produto #{produto.descricao} porém a quantidade de itens já foi atingida."
      msg_pedido = "A quantidade de itens do produto #{produto.descricao} já foi atingida."

      operacao.update(mensagem_erro: msg_operacao, status: "ERRO")
      operacao_pedido.update(erros: msg_pedido, status: "ERRO")

      return failure(status: :unprocessable_entity, error: "Quantidade de itens já atingida")
    end

    item = salvar_operacao_pedido_item(operacao_pedido, produto)

    success(
      codigo: produto.codigo,
      descricao: produto.descricao,
      ean: produto.ean,
      item_id: item.id
    )
  end

  private

  def salvar_operacao_pedido_item(operacao_pedido, produto)
    OperacaoPedidoItem.create!(
      operacao_pedido_id: operacao_pedido.id,
      codigo: produto.codigo,
      descricao: produto.descricao,
      lote: @params_operacao_pedido[:lote].to_s.strip,
      vencimento: @params_operacao_pedido[:vencimento].to_s.strip,
      fabricacao: @params_operacao_pedido[:fabricacao].to_s.strip,
      prazo: @params_operacao_pedido[:prazo].to_s.strip
    )
  end

  def success(payload)
    Result.new(success?: true, status: :ok, payload: payload)
  end

  def failure(status:, error:)
    Result.new(success?: false, status: status, payload: { error: error })
  end
end
