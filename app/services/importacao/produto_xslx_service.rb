class Importacao::Xlsx::AutoresService
  attr_accessor :arquivo_path, :evento

  def initialize(arquivo_path, evento)
    @arquivo_path = arquivo_path
    @evento = evento
  end

  def call!
    workbook = SimpleXlsxReader.open(arquivo_path)
    worksheets = workbook.sheets

    worksheets.each do |worksheet|
      worksheet.rows.each do |line|
        importar_linha(line)
      end
    end
  end

  def importar_linha(linha)
    autores = 0
    emails = 1
    trabalho = 2
    categoria = 3
    apresentacao = 4
    
    return if linha[autores].upcase == "AUTORES" || linha[autores].nil? rescue return

    begin
      nomes = linha[autores].split(",")
      emails = linha[emails].split(",")

      nomes.each_with_index do |nome, index|
        email = emails[index].strip

        autor = Autor.new
        autor.evento = @evento
        autor.email = email
        autor.nome = nome.strip
        autor.trabalho = linha[trabalho]
        autor.categoria = linha[categoria]
        autor.apresentacao = linha[apresentacao]
        autor.save
      end
            
    rescue Exception => e
      raise e
      Rails.logger.error e.message
    end
  end
end
