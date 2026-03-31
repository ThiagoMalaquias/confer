namespace :importacao do
  desc "Alterando status das coberturas"
  task produtos: :environment do
    Importacao.produto.where(status: "PENDENTE").find_each do |importacao|
      Importar::ProdutoService.new(importacao.relatorio).call!
      importacao.update(status: "CONCLUIDO")
    rescue Exception => e
      importacao.update(status: "ERRO", erros: e.message)
    end
  end

  desc "Alterando status das coberturas"
  task operacoes: :environment do
    Importacao.operacao.where(status: "PENDENTE").find_each do |importacao|
      Importar::Operacao::ModeloGeralService.new(importacao.relatorio).call!
      importacao.update(status: "CONCLUIDO")
    rescue Exception => e
      importacao.update(status: "ERRO", erros: e.message)
    end
  end
end
