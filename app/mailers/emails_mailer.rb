class EmailsMailer < ApplicationMailer
  def relatorio_pronto(relatorio, email)
    @relatorio = relatorio

    mail(to: email, subject: "Planilha importada com sucesso")
  end

  def relatorio_erro(relatorio, email)
    @relatorio = relatorio

    mail(to: email, subject: "Erro ao importar planilha")
  end

  def redefinir_senha(user, type)
    @user = user
    @reset_password_url = "#{type}/login/redefinir_senha/#{SecureRandom.uuid}/#{user.id}"

    mail(to: user.email, subject: "Redefinição de senha")
  end

  def pagamento_realizado(assinatura, email)
    @assinatura = assinatura
    contrato_digno

    mail(to: email, subject: "Pagamento realizado com sucesso")
  end

  def envio_contrato_cesteiro(cesteiro)
    @cesteiro = cesteiro
    contrato_digno

    mail(to: cesteiro.email, subject: "Contrato DIGNO Benefícios")
  end

  private

  def contrato_digno
    path = Rails.root.join('public', 'contrato-digno.pdf')
    attachments['contrato-digno.pdf'] = {
      mime_type: 'application/pdf',
      content:   File.binread(path)
    }
  end
end
