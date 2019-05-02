class ProductsController < ApplicationController
  def index
    @products = Product.all
    # logic for seeing all products of a given category..should go in model?
  end

  def show
    product_id = params[:id].to_i
    @product = Product.find_by(id: product_id)

    if @product.nil?
      flash[:error] = "That product does not exist"
      redirect_to products_path
    end
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
