class CreateOperacoes < ActiveRecord::Migration[6.1]
  def change
    create_table :operacoes do |t|
      t.integer :qtd
      t.integer :numero
      t.integer :pedido_venda
      t.text :observacao

      t.timestamps
    end
  end
end
