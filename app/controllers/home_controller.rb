class HomeController < ApplicationController
  before_action :require_login

  def index
    @notifications = Notification.where(receiver_id: current_user.id, status: "pending")
    @total_users = User.count
    @total_notes = Note.count
    @total_collections = Collection.count
  end
end
