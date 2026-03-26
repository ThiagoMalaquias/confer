class ProdutosController < ApplicationController
  before_action :set_produto, only: [:show, :edit, :update, :destroy]

  def index
    @produtos = Produto.order(descricao: :asc)
    @produtos = @produtos.where(codigo: params[:codigo].to_s.strip) if params[:codigo].present?
    @produtos = @produtos.where(ean: params[:ean].to_s.strip) if params[:ean].present?
    @produtos = @produtos.where(unc: params[:unc].to_s.strip) if params[:unc].present?

    if params[:descricao].present?
      termo = params[:descricao].to_s.strip
      like  = "%#{ActiveRecord::Base.sanitize_sql_like(termo)}%"
      @produtos = @produtos.where("descricao ILIKE ?", like)
    end

    @count = @produtos.count

    options = { page: params[:page] || 1, per_page: 10 }
    @produtos = @produtos.paginate(options)
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

  def set_produto
    @produto = Produto.find(params[:id])
  end

  def produto_params
    params.require(:produto).permit(:codigo, :ean, :descricao, :unc)
  end
end