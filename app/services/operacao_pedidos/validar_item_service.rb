class OperacaoPedidos::ValidarItemService
  Result = Struct.new(:success?, :status, :payload, keyword_init: true)

  DIAS_MINIMOS_PARA_VENCIMENTO = 60

  def initialize(id_operacao:, params_operacao_pedido:, current_user:)
    @id_operacao = id_operacao
    @params_operacao_pedido = params_operacao_pedido || {}
    @current_user = current_user
  end

  def call
    carregar_contexto!

    return produto_nao_encontrado unless produto
    return produto_fora_da_operacao unless produto_presente_na_operacao?
    return quantidade_excedida if quantidade_maxima_atingida?
    return vencimento_proximo if vencimento_por_fabricacao_proximo?
    return vencimento_proximo if vencimento_informado_proximo?

    item = criar_item!

    success(
      codigo: produto.codigo,
      descricao: produto.descricao,
      ean: produto.ean,
      item_id: item.id
    )
  end

  private

  attr_reader :produto

  def carregar_contexto!
    @operacao = Operacao.find(@id_operacao)
    @operacao_itens = @operacao.operacao_itens
    @operacao_pedido = @operacao.operacao_pedidos.first
    @operacao_pedido_itens = @operacao_pedido.operacao_pedido_itens
    @data_atual = Date.current

    ean = param(:ean)
    @produto = Produto.find_by("lower(ean) = lower(?)", ean)
  end

  def param(chave)
    @params_operacao_pedido[chave].to_s.strip
  end

  def produto_presente_na_operacao?
    @operacao_itens.where("descricao ILIKE ?", "%#{produto.codigo}%").exists?
  end

  def quantidade_maxima_atingida?
    quantidade_pedida = @operacao_pedido_itens.where(codigo: produto.codigo).count
    quantidade_operacao = @operacao_itens.where("descricao ILIKE ?", "%#{produto.codigo}%").last&.qtd || 1

    quantidade_pedida >= quantidade_operacao
  end

  def vencimento_por_fabricacao_proximo?
    return false if param(:fabricacao).blank? || param(:prazo).blank?

    data_fabricacao = parse_date(param(:fabricacao))
    return false unless data_fabricacao

    data_vencimento = data_fabricacao + param(:prazo).to_i.days
    vencimento_proximo?(data_vencimento)
  end

  def vencimento_informado_proximo?
    return false if param(:vencimento).blank?

    data_vencimento = parse_date(param(:vencimento))
    return false unless data_vencimento

    vencimento_proximo?(data_vencimento)
  end

  def vencimento_proximo?(data_vencimento)
    data_vencimento < (@data_atual + DIAS_MINIMOS_PARA_VENCIMENTO.days)
  end

  def parse_date(valor)
    Date.parse(valor)
  rescue ArgumentError, TypeError
    nil
  end

  def criar_item!
    OperacaoPedidoItem.create!(
      operacao_pedido_id: @operacao_pedido.id,
      codigo: produto.codigo,
      descricao: produto.descricao,
      lote: param(:lote),
      vencimento: param(:vencimento),
      fabricacao: param(:fabricacao),
      prazo: param(:prazo)
    )
  end

  def produto_nao_encontrado
    registrar_erro!(
      erro_operacao: "O operador da linha #{@current_user.nome} tentou adicionar o EAN #{param(:ean)}, porém o produto não foi encontrado.",
      erro_pedido: "O EAN #{param(:ean)} do produto não foi encontrado.",
      status_http: :not_found,
      mensagem: "Produto não encontrado"
    )
  end

  def produto_fora_da_operacao
    registrar_erro!(
      erro_operacao: "O operador da linha #{@current_user.nome} tentou adicionar o produto #{produto.descricao}, porém o produto não foi encontrado na operação.",
      erro_pedido: "O produto #{produto.descricao} não foi encontrado na operação.",
      status_http: :unprocessable_entity,
      mensagem: "Produto não encontrado na operação"
    )
  end

  def quantidade_excedida
    registrar_erro!(
      erro_operacao: "O operador da linha #{@current_user.nome} tentou adicionar o produto #{produto.descricao}, porém a quantidade de itens já foi atingida.",
      erro_pedido: "A quantidade de itens do produto #{produto.descricao} já foi atingida.",
      status_http: :unprocessable_entity,
      mensagem: "Quantidade de itens já atingida"
    )
  end

  def vencimento_proximo
    registrar_erro!(
      erro_operacao: "O operador da linha #{@current_user.nome} tentou adicionar o produto #{produto.descricao}, porém a data de vencimento está próxima de expirar.",
      erro_pedido: "A data de vencimento do produto #{produto.descricao} está próxima de expirar.",
      status_http: :unprocessable_entity,
      mensagem: "Data de vencimento próxima de expirar"
    )
  end

  def registrar_erro!(erro_operacao:, erro_pedido:, status_http:, mensagem:)
    @operacao.update!(mensagem_erro: erro_operacao, status: "ERRO")
    @operacao_pedido.update!(erros: erro_pedido, status: "ERRO")

    failure(status: status_http, error: mensagem)
  end

  def success(payload)
    Result.new(success?: true, status: :ok, payload: payload)
  end

  def failure(status:, error:)
    Result.new(success?: false, status: status, payload: { error: error })
  end
end