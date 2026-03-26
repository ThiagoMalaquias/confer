class OperacaoPedidos::ValidarProdutosService
  Result = Struct.new(:ok?, :errors, keyword_init: true)

  def initialize(operacao_pedido:)
    @operacao_pedido = operacao_pedido
    @operacao = operacao_pedido.operacao
  end

  def call
    esperados = produtos_esperados_por_codigo
    informados = produtos_informados_por_codigo

    erros = []

    todos_codigos = (esperados.keys + informados.keys).uniq
    todos_codigos.each do |codigo|
      qtd_esperada = esperados[codigo].to_i
      qtd_informada = informados[codigo].to_i

      next if qtd_esperada == qtd_informada

      if qtd_informada < qtd_esperada
        erros << "Produto #{codigo}: esperado #{qtd_esperada}, informado #{qtd_informada} (faltando #{qtd_esperada - qtd_informada})"
      else
        erros << "Produto #{codigo}: esperado #{qtd_esperada}, informado #{qtd_informada} (excedente #{qtd_informada - qtd_esperada})"
      end
    end

    Result.new(ok?: erros.empty?, errors: erros)
  end

  private

  # operacao_itens.descricao costuma vir como "CODIGO - DESCRICAO"
  # e qtd representa quantas unidades desse produto devem existir no pedido.
  def produtos_esperados_por_codigo
    hash = Hash.new(0)

    @operacao.operacao_itens.find_each do |item|
      codigo = extrair_codigo(item.descricao)
      next if codigo.blank?

      hash[codigo] += item.qtd.to_i
    end

    hash
  end

  def produtos_informados_por_codigo
    # conta quantas linhas foram inseridas no pedido por codigo
    @operacao_pedido
      .operacao_pedido_itens
      .group(:codigo)
      .count
  end

  def extrair_codigo(descricao)
    return if descricao.blank?
    descricao.to_s.split("-").first.to_s.strip
  end
end