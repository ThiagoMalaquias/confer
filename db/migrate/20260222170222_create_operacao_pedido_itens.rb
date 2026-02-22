class CreateOperacaoPedidoItens < ActiveRecord::Migration[6.1]
  def change
    create_table :operacao_pedido_itens do |t|
      t.references :operacao_pedido, null: false, foreign_key: true
      t.string :codigo
      t.text :descricao
      t.string :lote
      t.date :vencimento
      t.string :fabricacao
      t.string :prazo

      t.timestamps
    end
  end
end
