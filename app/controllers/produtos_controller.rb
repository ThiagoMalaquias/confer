class ProdutosController < ApplicationController
  PRODUTOS_BUSCA_SESSION_KEY = :produtos_busca
  PERMITTED_INDEX_KEYS = %i[codigo ean descricao unc sort direction].freeze

  before_action :set_produto, only: [:show, :edit, :update, :destroy]

  def index
    if params[:limpar].present?
      session.delete(PRODUTOS_BUSCA_SESSION_KEY)
      redirect_to produtos_path and return
    end

    filtros = params.permit(*PERMITTED_INDEX_KEYS).to_h
    if request.get? && filtros_na_url_vazios?(filtros) && session[PRODUTOS_BUSCA_SESSION_KEY].present?
      redirect_to produtos_path(session[PRODUTOS_BUSCA_SESSION_KEY]) and return
    end

    sort_column = %w[codigo ean descricao unc].include?(filtros[:sort]) ? filtros[:sort] : "descricao"
    sort_direction = %w[asc desc].include?(filtros[:direction]) ? filtros[:direction] : "asc"

    @produtos = Produto.order("#{sort_column} #{sort_direction}")
    @produtos = @produtos.where(codigo: filtros[:codigo].to_s.strip) if filtros[:codigo].present?
    @produtos = @produtos.where(ean: filtros[:ean].to_s.strip) if filtros[:ean].present?
    @produtos = @produtos.where(unc: filtros[:unc].to_s.strip) if filtros[:unc].present?

    if filtros[:descricao].present?
      termo = filtros[:descricao].to_s.strip
      like  = "%#{ActiveRecord::Base.sanitize_sql_like(termo)}%"
      @produtos = @produtos.where("descricao ILIKE ?", like)
    end

    @count = @produtos.count
    @produtos = @produtos.paginate(page: params[:page] || 1, per_page: 10)
   
    if filtros_para_salvar_na_sessao?(filtros)
      session[PRODUTOS_BUSCA_SESSION_KEY] = filtros
    end
  end

  def gerar_excel
    filtros = params.permit(*PERMITTED_INDEX_KEYS).to_h

    sort_column = %w[codigo ean descricao unc].include?(filtros[:sort]) ? filtros[:sort] : "descricao"
    sort_direction = %w[asc desc].include?(filtros[:direction]) ? filtros[:direction] : "asc"

    produtos = Produto.order("#{sort_column} #{sort_direction}")
    produtos = produtos.where(codigo: filtros[:codigo].to_s.strip) if filtros[:codigo].present?
    produtos = produtos.where(ean: filtros[:ean].to_s.strip) if filtros[:ean].present?
    produtos = produtos.where(unc: filtros[:unc].to_s.strip) if filtros[:unc].present?

    if filtros[:descricao].present?
      termo = filtros[:descricao].to_s.strip
      like  = "%#{ActiveRecord::Base.sanitize_sql_like(termo)}%"
      produtos = produtos.where("descricao ILIKE ?", like)
    end

    link = Exportar::ProdutosService.call("produtos.xlsx", produtos.pluck(:id))
    render json: { link: link }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def buscar
    @produto = Produto.find_by(codigo: params[:codigo])
    if @produto
      render json: { codigo: @produto.codigo, descricao: "#{@produto.codigo} - #{@produto.descricao}" }
    else
      render json: { error: "Produto não encontrado" }, status: :not_found
    end
  end

  def buscar_por_ean
    @produto = Produto.find_by(ean: params[:ean].to_s.strip)
    if @produto
      render json: { codigo: @produto.codigo, descricao: @produto.descricao, ean: @produto.ean }
    else
      render json: { error: "Produto não encontrado" }, status: :not_found
    end
  end

  def show; end

  def new
     @produto = Produto.new
     
     if params[:descricao].present?
      codigo, descricao = params[:descricao].strip.split("-")
      @produto.codigo = codigo.strip
      @produto.descricao = descricao.strip
     end
  end

  def create
    @produto = Produto.new(produto_params)
    if @produto.save
      redirect_to produtos_url, notice: 'Produto criado com sucesso'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @produto.update(produto_params)
      redirect_to produtos_url, notice: 'Produto atualizado com sucesso'
    else
      render :edit
    end
  end

  def destroy
    @produto.destroy
    redirect_to produtos_url, notice: 'Produto deletado com sucesso'
  end

  private

  def filtros_na_url_vazios?(f)
    f[:codigo].blank? && f[:ean].blank? && f[:descricao].blank? && f[:unc].blank? &&
      f[:sort].blank? && f[:direction].blank?
  end

  def filtros_para_salvar_na_sessao?(f)
    f[:codigo].present? || f[:ean].present? || f[:descricao].present? || f[:unc].present? ||
      f[:sort].present? || f[:direction].present?
  end

  def set_produto
    @produto = Produto.find(params[:id])
  end

  def produto_params
    params.require(:produto).permit(:codigo, :ean, :descricao, :unc, :requer_validacao_ean)
  end
end