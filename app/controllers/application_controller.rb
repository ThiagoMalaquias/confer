class ApplicationController < ActionController::Base
  before_action :authenticate_manager!

  def authenticate_manager!
    if cookies[:confer_admin].nil?
      redirect_to login_index_path
      return
    end
  
    if admin.present?
      return if instance_of?(::HomeController)

      if admin.acessos.blank?
         flash[:error] = "Usuário sem acesso a página"
         redirect_to "/"
         return false
      else
        unless admin.acessos_include?("#{self.class}::#{params[:action]}")
          flash[:error] = "Usuário sem acesso a página"
          redirect_to "/"
          return false
        end
      end
    end

    return true
  end

  def admin
    @current_user ||= Administrador.find(JsonWebToken.decode(cookies[:confer_admin])['id'])
  rescue => e
    cookies[:confer_admin] = nil
    redirect_to login_index_path
    return
  end
end
