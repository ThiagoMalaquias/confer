class AddRequerValidacaoEanToProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :produtos, :requer_validacao_ean, :boolean, default: true
  end
end
