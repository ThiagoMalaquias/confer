class CreateImportacoes < ActiveRecord::Migration[6.1]
  def change
    create_table :importacoes do |t|
      t.text :relatorio
      t.string :tipo
      t.string :status, default: 'PENDENTE'
      t.string :erros

      t.timestamps
    end
  end
end
