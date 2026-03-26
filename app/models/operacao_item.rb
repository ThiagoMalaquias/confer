class OperacaoItem < ApplicationRecord
  belongs_to :operacao

  def produto
    Produto.find_by(codigo: descricao.split("-")[0].strip) rescue nil
  end
end
