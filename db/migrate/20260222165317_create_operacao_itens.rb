class CreateOperacaoItens < ActiveRecord::Migration[6.1]
  def change
    create_table :operacao_itens do |t|
      t.references :operacao, null: false, foreign_key: true
      t.text :descricao
      t.integer :qtd

      t.timestamps
    end
  end
end
