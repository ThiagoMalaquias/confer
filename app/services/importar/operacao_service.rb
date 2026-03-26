require 'open-uri'
require 'tempfile'

class Importar::OperacaoService
  attr_accessor :arquivo_path

  def initialize(arquivo_path)
    @arquivo_path = arquivo_path
  end

  def call!
    temp = Tempfile.new(["importacao", ".xlsx"])
    temp.binmode
    temp.write(URI.open(arquivo_path).read)
    temp.close

    begin
      ActiveRecord::Base.transaction do
        workbook = SimpleXlsxReader.open(temp.path)

        workbook.sheets.each do |worksheet|
          processar_planilha(worksheet.rows)
        end
      end
    ensure
      temp.unlink
    end
  end

  private

  def processar_planilha(rows)
    operacao = nil
    lendo_composicao = false
    proxima_linha_e_observacao = false

    rows.each do |linha|
      linha = normalizar_linha(linha)
      texto = linha.reject(&:blank?).join(" ").strip

      next if linha_compeltamente_vazia?(linha)

      if inicio_operacao?(texto)
        salvar_operacao_com_itens(operacao) if operacao

        operacao = nova_operacao
        lendo_composicao = false
        proxima_linha_e_observacao = false
        next
      end

      next unless operacao

      if texto.include?("PEDIDOVENDA")
        operacao[:pedido_venda] = extrair_por_label(texto, "PEDIDOVENDA")
        operacao[:qtd] = extrair_por_label(texto, "QUANTIDADE") if texto.include?("QUANTIDADE")
        next
      end 

      if texto.include?("PEDIDO VENDA")
        operacao[:pedido_venda] = extrair_por_label(texto, "PEDIDO VENDA")
        operacao[:qtd] = extrair_por_label(texto, "QUANTIDADE") if texto.include?("QUANTIDADE")
        next
      end 

      if texto.include?("QUANTIDADE")
        operacao[:qtd] = extrair_por_label(texto, "QUANTIDADE")
        next
      end

      if texto.include?("COMPOSIÇÃO")
        lendo_composicao = true
        proxima_linha_e_observacao = false
        next
      end

      if texto.include?("OBSERVAÇÕES")
        lendo_composicao = false
        proxima_linha_e_observacao = true
        next
      end

      if proxima_linha_e_observacao
        operacao[:observacao] = texto.presence unless texto.include?("ASSINATURAS:")
        proxima_linha_e_observacao = false
        next
      end

      if lendo_composicao
        item = montar_item_composicao(linha)
        operacao[:itens] << item if item.present?
      end
    end

    salvar_operacao_com_itens(operacao) if operacao
  end

  def nova_operacao
    {
      pedido_venda: nil,
      qtd: nil,
      observacao: nil,
      itens: []
    }
  end

  def salvar_operacao_com_itens(dados)
    return if dados.blank?
    return if dados[:pedido_venda].blank? && dados[:itens].blank?

    operacao = Operacao.create!(
      pedido_venda: dados[:pedido_venda],
      qtd: dados[:qtd].presence || 1,
      observacao: dados[:observacao].presence
    )

    dados[:itens].each do |item|
      operacao.operacao_itens.create!(
        descricao: item[:descricao],
        qtd: item[:qtd]
      )
    end
  end

  def montar_item_composicao(linha)
    linha = linha.dup
    linha[0] = 1 if linha[0].blank?
    linha[1] = 1 if linha[1].blank?

    celulas = linha.reject(&:blank?)
    return nil if celulas.blank?

    texto = celulas.join(" ").strip
    return nil if texto.include?("Qtd")
    return nil if texto.include?("Descrição")
    return nil if texto.include?("Unidade")
    return nil if texto.include?("Total")
    return nil if texto.include?("COMPOSIÇÃO")

    qtd = extrair_qtd_item(celulas)
    return nil if qtd <= 0

    descricao = extrair_descricao_item(celulas)
    return nil if descricao.blank?

    {
      qtd: qtd,
      descricao: descricao
    }
  end

  def extrair_qtd_item(celulas)
    segunda = celulas.second.to_s.strip
    return 0 unless segunda.match?(/\A\d+\z/)

    segunda.to_i
  end

  def extrair_descricao_item(celulas)
    celulas.fetch(2, "").to_s.squish
  end

  def extrair_por_label(texto, label)
    texto = texto.gsub("\n", " ")
  
    regex = /#{label}\s*[:]*\s*([\d.,]+)/i
    match = texto.match(regex)
  
    return nil unless match
  
    match[1].to_s.gsub(",", ".").to_f.to_i
  end

  def inicio_operacao?(texto)
    texto.include?("DADOS DO PEDIDO")
  end

  def normalizar_linha(linha)
    linha.map { |c| c.to_s.strip }
  end

  def linha_compeltamente_vazia?(linha)
    linha.all?(&:blank?)
  end
end