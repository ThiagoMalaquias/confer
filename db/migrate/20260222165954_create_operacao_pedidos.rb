class CreateOperacaoPedidos < ActiveRecord::Migration[6.1]
  def change
    create_table :operacao_pedidos do |t|
      t.references :operacao, null: false, foreign_key: true
      t.references :administrador, null: false, foreign_key: true
      t.string :codigo
      t.string :status
      t.text :observacao
      t.text :erros

      t.timestamps
    end
  end
end
