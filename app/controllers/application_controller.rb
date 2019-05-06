class ApplicationController < ActionController::Base
  def require_login
    @user = User.find_by(id: session[:user_id])
    if @user.nil?
      flash[:error] = "You must be logged in to view this page!"
      redirect_to root_path
    end
  end
end
