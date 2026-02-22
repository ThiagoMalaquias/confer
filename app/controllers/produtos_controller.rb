class ProdutosController < ApplicationController
  before_action :set_produto, only: [:show, :edit, :update, :destroy]

  def index
    @produtos = Produto.all

    options = { page: params[:page] || 1, per_page: 10 }
    @produtos = @produtos.paginate(options)
  end

  def show
  end

  def new
    @produto = Produto.new
  end

  def create
    @produto = Produto.new(produto_params)
    if @produto.save
      redirect_to produtos_url, notice: 'Produto criado com sucesso'
    else
      render :new
    end
  end

  def edit
  end

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