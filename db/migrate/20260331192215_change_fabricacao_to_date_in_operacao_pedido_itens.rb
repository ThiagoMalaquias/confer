class ChangeFabricacaoToDateInOperacaoPedidoItens < ActiveRecord::Migration[6.1]
  def up
    change_column :operacao_pedido_itens,
                  :fabricacao,
                  "date USING NULLIF(fabricacao, '')::date"
  end

  def down
    change_column :operacao_pedido_itens, :fabricacao, :string
  end
end