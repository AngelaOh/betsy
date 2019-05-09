class ProductsController < ApplicationController
  before_action :find_product, only: [:edit, :update, :retire]

  def root
    @products = Product.all.sort_by { |product| product.created_at }
  end

  def index
    @products = Product.where(retired: false)
    # logic for seeing all products of a given category..should go in model?
  end

  def show
    product_id = params[:id].to_i
    @product = Product.find_by(id: product_id, retired: false)
    # raise
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
    @product.user_id = params[:user_id]
    @product.save

    if @product.save
      flash[:success] = "Successfully created new product #{@product.name}"
      redirect_to product_path(@product.id)
    else
      flash.now[:error] = "Could not create new product #{@product.name}"
      flash.now[:messages] = @product.errors.messages
      render :new, status: :bad_request
    end
  end

  def edit
  end

  def update
    is_successful = @product.update(product_params)
    if is_successful
      flash[:success] = "#{@product.name} updated successfully!"
      redirect_to product_path(@product.id)
    else
      flash.now[:error] = "Could not edit this product."
      flash.now[:messages] = @product.errors.messages
      render :edit, status: :bad_request
    end
  end

  def retire
    if !@product.retired
      @product.update(retired: true)
      flash[:success] = "Successfully removed/retired #{@product.name} from Toonsy"
    else
      @product.update(retired: false)
      flash[:success] = "Product #{@product.name} is now available to be sold on Toonsy"
    end

    redirect_back fallback_location: root_path
  end

  private

  def product_params
    params.require(:product).permit(:name, :price, :inventory, :photo_url, :description, category_ids: [])
  end

  def find_product
    @product = Product.find_by(id: params[:id])
    head :not_found unless @product
  end
end
