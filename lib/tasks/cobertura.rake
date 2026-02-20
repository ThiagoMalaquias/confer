namespace :cobertura do
  desc "Alterando status das coberturas"
  task alterar_status: :environment do
    FuncionarioCobertura.ativas.where("fim < ?", Time.zone.now).find_each do |cobertura|
      cobertura.update(status: "VENCIDO")
    end

    Funcionario.find_each do |funcionario|
      if funcionario.coberturas.ativas.empty? && funcionario.coberturas.aguardando_ativacao.empty?
        funcionario.update(status: "INATIVO")
      end
    end
  end
end
