class CreateGrupoAcessos < ActiveRecord::Migration[6.1]
  def change
    create_table :grupo_acessos do |t|
      t.string :nome
      t.string :acessos

      t.timestamps
    end
  end
end
