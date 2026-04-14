namespace :dev_jobs do
  desc "Limpando base de dados 1x por mês"
  task limpar_base_dados: :environment do
    Operacao.concluido.where("created_at < ?", 1.month.ago).destroy_all
    Importacao.where("created_at < ?", 1.month.ago).destroy_all
  end
end
