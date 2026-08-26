class SessionsController < ApplicationController
  def new
  end

  def create
    begin
      @user = User.find_by(name: params[:name])
      if @user && @user.authenticate(params[:password])
        session[:user] = @user.name

        # Buscar notificaciones del usuario actual
        @notifications = @user.notifications

        redirect_to home_path, notice: "Logged in successfully!"
      else
        flash.now[:alert] = "Invalid name or password"
        render :new
      end
    rescue Mongoid::Errors::DocumentNotFound
      flash.now[:alert] = "User not found"
      render :new
    end
  end

  def destroy
    session[:user] = nil
    session[:myroute] = nil
    redirect_to root_path, notice: "Logged out successfully!"
  end
end
