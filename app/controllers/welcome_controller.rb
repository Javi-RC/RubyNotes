class WelcomeController < ApplicationController
  layout "landing"

  def index
    redirect_to home_path if current_user
  end
end
