class ApplicationController < ActionController::Base
  before_action :authenticate_manager!, :admin

  def authenticate_manager!
    return unless cookies[:confer_admin].nil?

    redirect_to login_index_path
    return
  end

  def admin
    @current_user ||= Administrador.find(JsonWebToken.decode(cookies[:confer_admin])['id'])
  rescue => e
    cookies[:confer_admin] = nil
    redirect_to login_index_path
    return
  end
end
