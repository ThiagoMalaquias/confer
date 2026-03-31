# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2026_03_31_192215) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "acessos", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "administrador_grupo_acessos", force: :cascade do |t|
    t.bigint "administrador_id", null: false
    t.bigint "grupo_acesso_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["administrador_id"], name: "index_administrador_grupo_acessos_on_administrador_id"
    t.index ["grupo_acesso_id"], name: "index_administrador_grupo_acessos_on_grupo_acesso_id"
  end

  create_table "administradores", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.string "senha"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "grupo_acessos", force: :cascade do |t|
    t.string "nome"
    t.string "acessos"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "importacoes", force: :cascade do |t|
    t.text "relatorio"
    t.string "tipo"
    t.string "status", default: "PENDENTE"
    t.string "erros"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "operacao_itens", force: :cascade do |t|
    t.bigint "operacao_id", null: false
    t.text "descricao"
    t.integer "qtd"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["operacao_id"], name: "index_operacao_itens_on_operacao_id"
  end

  create_table "operacao_pedido_itens", force: :cascade do |t|
    t.bigint "operacao_pedido_id", null: false
    t.string "codigo"
    t.text "descricao"
    t.string "lote"
    t.date "vencimento"
    t.date "fabricacao"
    t.string "prazo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["operacao_pedido_id"], name: "index_operacao_pedido_itens_on_operacao_pedido_id"
  end

  create_table "operacao_pedidos", force: :cascade do |t|
    t.bigint "operacao_id", null: false
    t.bigint "administrador_id", null: false
    t.string "codigo"
    t.string "status"
    t.text "observacao"
    t.text "erros"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["administrador_id"], name: "index_operacao_pedidos_on_administrador_id"
    t.index ["operacao_id"], name: "index_operacao_pedidos_on_operacao_id"
  end

  create_table "operacoes", force: :cascade do |t|
    t.integer "qtd"
    t.integer "numero"
    t.integer "pedido_venda"
    t.text "observacao"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "PENDENTE"
    t.text "mensagem_erro"
  end

  create_table "produtos", force: :cascade do |t|
    t.string "codigo"
    t.text "ean"
    t.text "descricao"
    t.string "unc"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "administrador_grupo_acessos", "administradores"
  add_foreign_key "administrador_grupo_acessos", "grupo_acessos"
  add_foreign_key "operacao_itens", "operacoes"
  add_foreign_key "operacao_pedido_itens", "operacao_pedidos"
  add_foreign_key "operacao_pedidos", "administradores"
  add_foreign_key "operacao_pedidos", "operacoes"
end
