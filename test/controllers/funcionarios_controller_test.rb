require "test_helper"

class FuncionariosControllerTest < ActionDispatch::IntegrationTest
  test "should get acesso" do
    get funcionarios_acesso_url
    assert_response :success
  end
end
