require "application_system_test_case"

class AdministradoresTest < ApplicationSystemTestCase
  setup do
    @administrador = administradores(:one)
  end

  test "visiting the index" do
    visit administradores_url
    assert_selector "h1", text: "Administradores"
  end

  test "should create administrador" do
    visit administradores_url
    click_on "New administrador"

    fill_in "Email", with: @administrador.email
    fill_in "Nome", with: @administrador.nome
    fill_in "Senha", with: @administrador.senha
    click_on "Create Administrador"

    assert_text "Administrador was successfully created"
    click_on "Back"
  end

  test "should update Administrador" do
    visit administrador_url(@administrador)
    click_on "Edit this administrador", match: :first

    fill_in "Email", with: @administrador.email
    fill_in "Nome", with: @administrador.nome
    fill_in "Senha", with: @administrador.senha
    click_on "Update Administrador"

    assert_text "Administrador was successfully updated"
    click_on "Back"
  end

  test "should destroy Administrador" do
    visit administrador_url(@administrador)
    click_on "Destroy this administrador", match: :first

    assert_text "Administrador was successfully destroyed"
  end
end
