class ProductsController < ApplicationController
  def index
    @products = Product.all
    # logic for seeing all products of a given category..should go in model?
  end

  def show
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
