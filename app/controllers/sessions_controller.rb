class SessionsController < ApplicationController
  def new; end

  def create
    # .where(...).first avoids Mongoid's find_by, which raises when there is no
    # match. A single message for both "no such user" and "wrong password"
    # also stops the form from confirming which usernames exist.
    user = User.where(name: params[:name]).first

    if user&.authenticate(params[:password])
      session[:user_id] = user.id.to_s
      redirect_to home_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid name or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out successfully!"
  end
end
