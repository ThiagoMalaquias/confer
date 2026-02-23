class AddStatusToOperacao < ActiveRecord::Migration[6.1]
  def change
    add_column :operacoes, :status, :string, default: "PENDENTE"
  end
end
