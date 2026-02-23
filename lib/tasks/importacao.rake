namespace :importacao do
  desc "Alterando status das coberturas"
  task produtos: :environment do
    Importacao.produto.where(status: "PENDENTE").find_each do |importacao|
      Importar::ProdutoXlsxService.new(importacao.relatorio).call!
      importacao.update(status: "CONCLUIDO")
    rescue Exception => e
      importacao.update(status: "ERRO", erros: e.message)
    end
  end

  desc "Alterando status das coberturas"
  task operacoes: :environment do
    Importacao.operacao.where(status: "PENDENTE").find_each do |importacao|
      # Importar::OpPdfService.new(importacao.relatorio).call!
      # importacao.update(status: "CONCLUIDO")
    rescue Exception => e
    end
  end

  desc "Mock de operações"
  task operacoes_mock: :environment do
    produtos = Produto.all.to_a
    usar_produtos = produtos.size >= 3

    100.times do |i|
      numero = rand(1000..9999)
      pedido_venda = rand(100_000..999_999)
      qtd_total = rand(1..10)
      operacao = Operacao.create!(
        numero: numero,
        pedido_venda: pedido_venda,
        qtd: qtd_total,
        status: "PENDENTE"
      )

      qtd_itens = rand(1..15)
      qtd_itens.times do
        if usar_produtos
          p = produtos.sample
          descricao = [p.codigo, p.descricao].compact.join(" - ")
          descricao = "Item mock" if descricao.blank?
        else
          codigo = "COD#{rand(1000..9999)}"
          descricao = "#{codigo} - Produto mock #{rand(100..999)}"
        end
        operacao.operacao_itens.create!(
          descricao: descricao,
          qtd: rand(1..10)
        )
      end
    end
  end
end
