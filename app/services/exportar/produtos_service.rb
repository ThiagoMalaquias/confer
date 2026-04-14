class Exportar::ProdutosService  
  def self.call(filename, produto_ids)
    require 'write_xlsx'

    produtos = Produto.where(id: produto_ids)

    workbook = WriteXLSX.new("/tmp/#{filename}")
    worksheet = workbook.add_worksheet

    format = workbook.add_format
    format.set_bold

    worksheet.write(0, 0, "Código", format)
    worksheet.write(0, 1, "EAN", format)
    worksheet.write(0, 2, "Descrição", format)
    worksheet.write(0, 3, "UNC", format)
    worksheet.write(0, 4, "Requer Validação EAN", format)

    i = 1
    produtos.each do |produto|  
      worksheet.write(i, 0, produto.codigo)
      worksheet.write(i, 1, produto.ean)
      worksheet.write(i, 2, produto.descricao)
      worksheet.write(i, 3, produto.unc)
      worksheet.write(i, 4, produto.requer_validacao_ean ? "Sim" : "Não")
      i += 1
    end

    workbook.close

    AwsService.upload("/tmp/#{filename}", filename)
  end
end