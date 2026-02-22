class CreateProdutos < ActiveRecord::Migration[6.1]
  def change
    create_table :produtos do |t|
      t.string :codigo
      t.text :ean
      t.text :descricao
      t.string :unc

      t.timestamps
    end
  end
end
