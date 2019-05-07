class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    category_id = params[:id].to_i
    @category = Category.find_by(id: category_id)

    if @category.nil?
      flash[:error] = "That category does not exist"
      redirect_back(fallback_location: root_path)
    end
  end
end
