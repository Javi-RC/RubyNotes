class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(name: params[:name])
    if @user&.authenticate(params[:password])
      session[:user_id] = @user.id.to_s
      redirect_to home_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid name or password"
      render :new
    end
  rescue Mongoid::Errors::DocumentNotFound
    flash.now[:alert] = "User not found"
    render :new
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out successfully!"
  end
end
