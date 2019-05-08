class UsersController < ApplicationController
  before_action :find_user, only: [:show]
  before_action :require_login, only: [:show, :destroy]

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    if !@user
      flash[:status] = :failure
      flash[:result_text] = "User not found!"
      redirect_to root_path
    end
  end

  def login
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user
      flash[:success] = "Logged in as returning user #{user.username}"
    else
      user = User.build_from_github(auth_hash)

      if user.save
        flash[:success] = "Logged in as new user #{user.username}"
      else
        flash[:status] = :failure
        flash[:result_text] = "Could not create new user account."
        return redirect_to root_path
      end
      #redirct to homepage
    end

    session[:user_id] = user.id
    return redirect_to root_path
  end

  def current
    @current_user = User.find_by(id: session[:user_id])
    if @current_user.nil?
      flash[:error] = "You must be logged in first!"
      redirect_to users_path
    end
  end

  def destroy
    user = User.find_by(id: session[:user_id])
    session[:user_id] = nil
    flash[:notice] = "Logged out #{user.username}"
    redirect_to root_path
  end

  private

  def find_user
    @user = User.find_by(id: params[:id])
  end
end
