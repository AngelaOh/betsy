class UsersController < ApplicationController
  before_action :find_user, only: [:show]

  def index
    @users = User.all
  end

  def show
    if @user.nil?
      flash[:status] = :failure
      flash[:result_text] = "User not found!"
      redirect_to users_path # AO: Where should we redirect this?
    end
  end

  private

  def find_user
    @user = User.find_by(id: params[:id])
  end
end
