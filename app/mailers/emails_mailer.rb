class EmailsMailer < ApplicationMailer
  def operacao_concluida(operacao, email)
    @operacao = operacao

    mail(to: email, subject: "Montagens Cestas - Capital das Cestas - Pedido #{operacao.pedido_venda}")
  end

  def operacao_cancelada(operacao, email)
    @operacao = operacao

    mail(to: email, subject: "Montagens Cestas - Capital das Cestas - Pedido #{operacao.pedido_venda} - CANCELADA")
  end
end
