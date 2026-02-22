class LoginController < ApplicationController
  skip_before_action :authenticate_manager!, :admin
  layout "login"

  def index; end

  def sign_in
    @manager = Administrador.find_by(email: params[:email], senha: params[:senha])
    if @manager
      time = 1.year.from_now
      payload = { id: @manager.id, name: @manager.nome }
      cookies[:confer_admin] = { value: JsonWebToken.encode(payload), expires: time, httponly: true }

      redirect_to root_path
    else
      flash[:error] = "Email ou senha inválidos"
      redirect_to login_index_path
    end
  end

  def sign_up
    cookies[:confer_admin] = nil
    redirect_to login_index_path
  end
end
