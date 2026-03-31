class OperacaoPedidos::PrefillItensSemValidacaoEanService
  def initialize(operacao_pedido:)
    @operacao_pedido = operacao_pedido
    @operacao = operacao_pedido.operacao
  end

  def call
    return if @operacao.status == "CONCLUIDO"

    esperados = produtos_esperados_por_codigo
    informados = @operacao_pedido.operacao_pedido_itens.group(:codigo).count

    esperados.each do |codigo, qtd_esperada|
      produto = Produto.find_by(codigo: codigo)
      next if produto.nil?
      next if produto.requer_validacao_ean?

      atual = informados[codigo].to_i
      faltando = qtd_esperada - atual
      next if faltando <= 0

      faltando.times do
        OperacaoPedidoItem.create!(
          operacao_pedido_id: @operacao_pedido.id,
          codigo: produto.codigo,
          descricao: produto.descricao,
          lote: nil,
          vencimento: nil,
          fabricacao: nil,
          prazo: nil
        )
      end

      informados[codigo] = atual + faltando
    end
  end

  private

  def produtos_esperados_por_codigo
    hash = Hash.new(0)

    @operacao.operacao_itens.find_each do |item|
      codigo = extrair_codigo(item.descricao)
      next if codigo.blank?

      hash[codigo] += item.qtd.to_i
    end

    hash
  end

  def extrair_codigo(descricao)
    return if descricao.blank?

    descricao.to_s.split("-").first.to_s.strip
  end
end