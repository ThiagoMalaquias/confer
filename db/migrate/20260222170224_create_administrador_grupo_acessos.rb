class CreateAdministradorGrupoAcessos < ActiveRecord::Migration[6.1]
  def change
    create_table :administrador_grupo_acessos do |t|
      t.references :administrador, null: false, foreign_key: true
      t.references :grupo_acesso, null: false, foreign_key: true

      t.timestamps
    end
  end
end
