class ApplicationController < ActionController::Base
  def require_login
    @merchant = User.find_by(id: session[:user_id])

    if @merchant.nil?
      flash[:error] = "You must be logged in to view this page!"
      redirect_to root_path
    elsif params[:id] != @merchant.id.to_s
    # elsif (1 <= params[:id].to_i) && (params[:id].to_i <= User.all.length) && params[:id] != @merchant.id.to_s
      flash[:error] = "Must be this merchant to view page!"
      redirect_to root_path
    end
  end
end
