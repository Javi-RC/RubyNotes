class HomeController < ApplicationController
  before_action :require_login

  def index
    @notifications = Notification.where(receiver_id: current_user.id, status: "pending")
  end
end
