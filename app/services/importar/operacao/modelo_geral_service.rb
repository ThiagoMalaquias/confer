require 'open-uri'
require 'tempfile'

class Importar::Operacao::ModeloGeralService
  attr_accessor :arquivo_path

  COL_PEDIDO_VENDA = 0
  COL_QTD_PEDIDO   = 1
  COL_QTD_ITEM     = 4
  COL_DESCRICAO    = 5
  COL_OBSERVACAO   = 9

  def initialize(arquivo_path)
    @arquivo_path = arquivo_path
  end

  def call!
    temp = Tempfile.new(["importacao", ".xlsx"])
    temp.binmode
    temp.write(URI.open(arquivo_path).read)
    temp.close

    begin
      workbook = SimpleXlsxReader.open(temp.path)

      ActiveRecord::Base.transaction do
        workbook.sheets.each do |worksheet|
          importar_planilha(worksheet)
        end
      end
    ensure
      temp.unlink
    end
  end

  private

  def importar_planilha(worksheet)
    operacoes_agrupadas = {}

    worksheet.rows.each_with_index do |linha, index|
      next if linha_em_branco?(linha)
      next if cabecalho?(linha)

      pedido_venda = to_integer(linha[COL_PEDIDO_VENDA])
      next if pedido_venda.blank?

      operacoes_agrupadas[pedido_venda] ||= {
        qtd: to_integer(linha[COL_QTD_PEDIDO]),
        observacao: presence(linha[COL_OBSERVACAO]),
        itens: []
      }

      operacoes_agrupadas[pedido_venda][:observacao] ||= presence(linha[COL_OBSERVACAO])

      descricao_item = presence(linha[COL_DESCRICAO])
      qtd_item       = to_integer(linha[COL_QTD_ITEM])

      next if descricao_item.blank?

      operacoes_agrupadas[pedido_venda][:itens] << {
        descricao: descricao_item,
        qtd: qtd_item
      }
    end

    operacoes_agrupadas.each do |pedido_venda, dados|
      operacao = Operacao.find_or_initialize_by(pedido_venda: pedido_venda)
      operacao.qtd = dados[:qtd]
      operacao.observacao = dados[:observacao]
      operacao.save!

      operacao.operacao_itens.destroy_all

      dados[:itens].each do |item|
        operacao.operacao_itens.create!(
          descricao: item[:descricao],
          qtd: item[:qtd]
        )
      end
    end
  end

  def cabecalho?(linha)
    linha[COL_PEDIDO_VENDA].to_s.strip.upcase == "PEDIDO"
  end

  def linha_em_branco?(linha)
    linha.compact.map { |v| v.to_s.strip }.all?(&:blank?)
  end

  def to_integer(valor)
    return nil if valor.nil?

    valor.to_i
  end

  def presence(valor)
    texto = valor.to_s.strip
    texto.present? ? texto : nil
  end
end