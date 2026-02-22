class CreateAcessos < ActiveRecord::Migration[6.1]
  def change
    create_table :acessos do |t|
      t.string :nome

      t.timestamps
    end
  end
end
