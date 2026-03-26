class EmailsMailer < ApplicationMailer
  def operacao_concluida(operacao)
    @operacao = operacao

    mail(to: "tammalaquias@gmail.com", subject: "Montagens Cestas - Capital das Cestas - Pedido #{operacao.pedido_venda}")
  end
end
