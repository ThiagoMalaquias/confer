class GrupoAcessosController < ApplicationController
  before_action :set_grupo_acesso, only: %i[show edit update destroy]

  def index
    @grupo_acessos = GrupoAcesso.all
  end

  def show; end

  def new
    load_access
    @grupo_acesso = GrupoAcesso.new
  end

  def edit
    load_access
  end

  def create
    @grupo_acesso = GrupoAcesso.new(grupo_acesso_params)
    @grupo_acesso.acessos = parseAcesso
    @grupo_acesso.administradores = params[:grupo_acesso][:administradores]

    respond_to do |format|
      if @grupo_acesso.save
        format.html { redirect_to grupo_acessos_url, notice: 'Grupo acesso foi criado com sucesso.' }
        format.json { render :show, status: :created, location: @grupo_acesso }
      else
        format.html { render :new }
        format.json { render json: @grupo_acesso.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      @grupo_acesso.update(grupo_acesso_params)
      @grupo_acesso.nome = grupo_acesso_params[:nome]
      @grupo_acesso.acessos = parseAcesso
      @grupo_acesso.administradores = params[:grupo_acesso][:administradores]
      if @grupo_acesso.save
        format.html { redirect_to grupo_acessos_url, notice: 'Grupo acesso foi atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @grupo_acesso }
      else
        format.html { render :edit }
        format.json { render json: @grupo_acesso.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @grupo_acesso.destroy
    respond_to do |format|
      format.html { redirect_to grupo_acessos_url, notice: 'Grupo acesso foi excluído com sucesso.' }
      format.json { head :no_content }
    end
  end

  private

  def parseAcesso
    acessos = params["grupo_acesso"]["actions"].map do |g_acesso|
      { acesso: g_acesso }
    end
    acessos.to_json
    rescue
      "[]"      
  end 

  def set_grupo_acesso
    @grupo_acesso = GrupoAcesso.find(params[:id])
  end

  def grupo_acesso_params
    params.require(:grupo_acesso).permit(:nome, :acessos)
  end

  def load_access
    @menu = []

    item = {
      nome: "Dashboard",
      itens: [
        {
          controllers: [
            {
              controller: "HomeController",
              nome: "Home",
              actions: []
            }
          ]
        }
      ]
    }

    @menu << prepare_item_subs(item)

    item = {
      nome: "Vendas",
      itens: [
        {
          controllers: [
            {
              controller: "VendasController",
              nome: "Vendas",
              actions: []
            }
          ]
        }
      ]
    }

    @menu << prepare_item_subs(item)
    
    item = {
      nome: "Filiais",
      itens: [
        {
          controllers: [
            {
              controller: "FiliaisController",
              nome: "Filiais",
              actions: []
            },
            {
              controller: "FilialProdutosController",
              nome: "Filial Produtos",
              actions: []
            }
          ]
        }
      ]
    }

    @menu << prepare_item_subs(item)

    item = {
      nome: "Adminstrativo",
      itens: [
        {
          controllers: [
            {
              controller: "AdministradoresController",
              nome: "Administradores",
              actions: []
            },
            {
              controller: "GrupoAcessosController",
              nome: "Grupo Acessos",
              actions: []
            },
            {
              controller: "FinanceirosController",
              nome: "Financeiro",
              actions: []
            }
          ]
        }
      ]
    }

    @menu << prepare_item_subs(item)

    item = {
      nome: "Produtos",
      itens: [
        {
          controllers: [
            {
              controller: "ProdutosController",
              nome: "Produtos",
              actions: []
            },
            {
              controller: "GrupoProdutosController",
              nome: "Grupos",
              actions: []
            },
            {
              controller: "EstoquesController",
              nome: "Estoque",
              actions: []
            }
          ]
        }
      ]
    }

    @menu << prepare_item_subs(item)

    @administradores = Administrador.order("nome asc")    
  end

  def prepare_item_subs(item)
    item[:itens].each do |item|
      item[:controllers].each do |controller|
        next if controller[:actions].present?

        set_actions(controller)
        next if controller[:controllers].blank?

        controller[:controllers].each do |controller2|
          set_actions(controller2) if controller2[:actions].blank?
        end
      end
    end

    item
  end
  
  def set_actions(controller)
    actions = controller[:controller].constantize.action_methods.collect(&:to_s)
    actions.each do |action|
      views = []
      nome_action = action_amigavel(action)
      next if nome_action.blank?

      controller[:actions] << {
        action:,
        nome: nome_action,
        views:
      }
    end
  end
    
  def action_amigavel(action)
    nomes = {
      new: "Mostrar tela de novo registro",
      index: "Mostre tela inicial",
      certificado_gerar: "Gerar Certificado",
      update: "Atualizar registro",
      create: "Criar registro",
      destroy: "Apagar registro",
      show: "Mostrar registro",
      edit: "Mostrar tela de edição",
      importar: "Importar",
      produtos_mais_vendidos: "Produtos mais vendidos",
      alterar_status: "Alterar status",
      por_codigo_barras: "Buscar por código de barras"
    }
    
    nomes[action.to_sym]
  end
  
end
