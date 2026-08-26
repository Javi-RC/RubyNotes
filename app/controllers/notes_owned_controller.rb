class NotesOwnedController < ApplicationController
  before_action :require_login

  def index
    @user = current_user
    @notes = @user.notes || []
    @sharednotes = []
    friend_ids = @user.friend_ids || []

    if friend_ids.any?
      shared_notes = Note.where(:share_ids.in => [current_user.id], :user_id.nin => [current_user.id])
      @sharednotes = shared_notes.to_a
    end

    @notifications = Notification.where(receiver_id: current_user.id, status: "pending")
  end
end
