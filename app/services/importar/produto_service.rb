require 'open-uri'
require 'tempfile'

class Importar::ProdutoService
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
        worksheets = workbook.sheets
        worksheets.each do |worksheet|
          worksheet.rows.each do |line|
            importar_linha(line)
          end
        end
      end
    ensure
      temp.unlink
    end
  end

  def importar_linha(linha)
    codigo = 4
    ean = 5
    descricao = 6
    unc = 7

    return if linha[codigo].upcase == "IDPROD" || linha[codigo].nil? rescue return

    produto = Produto.find_or_initialize_by(codigo: linha[codigo])
    produto.ean = linha[ean]
    produto.descricao = linha[descricao]
    produto.unc = linha[unc]
    produto.save
  end
end