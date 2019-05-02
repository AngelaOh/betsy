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
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      flash[:success] = "Successfully created new product #{@product.name}"
      # redirect_to user_product_path(@product.user.id)
    else
      flash[:error] = "Could not create new product #{@product.name}"
      flash[:messages] = @product.errors.messages
      render :new, status: :bad_request
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def product_params
    params.require(:product).permit(:name, :price, :inventory)
  end
end
