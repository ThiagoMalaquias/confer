class AddMensagemErroToOperacao < ActiveRecord::Migration[6.1]
  def change
    add_column :operacoes, :mensagem_erro, :text
  end
end
