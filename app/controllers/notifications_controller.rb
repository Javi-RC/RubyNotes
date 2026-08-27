class NotificationsController < ApplicationController
  include Paginatable

  before_action :require_login
  # Every member action loads through the current user's own inbox, so a
  # notification addressed to someone else is simply not found. Previously
  # update/destroy/deny took any id and acted on it.
  before_action :set_notification, only: %i[update destroy accept deny]

  def index
    scope = own_notifications.order(notification_type: 1)
    @notifications = paginate(scope, per_page: 20)
  end

  def update
    if @notification.update(notification_params)
      redirect_to notifications_path, notice: "Notification was successfully updated."
    else
      redirect_to notifications_path, alert: "Failed to update notification."
    end
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path, notice: "Notification deleted successfully."
  end

  def accept
    case @notification.notification_type
    when "friend_request"
      accept_friend_request(@notification)
    when "note_share"
      accept_note_share(@notification)
    when "collection_share"
      accept_collection_share(@notification)
    else
      redirect_to notifications_path, alert: "Unknown notification type."
    end
  end

  def deny
    @notification.update(status: "denied")
    redirect_to notifications_path, notice: "Request denied successfully."
  end

  private

  def own_notifications
    Notification.where(receiver_id: current_user.id)
  end

  def set_notification
    # .where(...).first, not find_by: Mongoid's find_by raises
    # DocumentNotFound, which would surface as a 404 instead of this redirect.
    @notification = own_notifications.where(id: params[:id]).first
    return if @notification

    redirect_to notifications_path, alert: "That notification is not available."
  end

  # Only :status is permitted. The old param list let a caller rewrite
  # sender_id, receiver_id and share_id, which is enough to forge a share.
  def notification_params
    params.require(:notification).permit(:status)
  end

  def accept_friend_request(notification)
    sender = User.find(notification.sender_id)
    current_user.friends << sender
    sender.friends << current_user
    notification.update(status: "accepted")

    Notification.create!(
      notification_type: "friendship_response",
      status: "unread",
      message: "#{current_user.name} has accepted your friendship!",
      sender_id: current_user.id,
      receiver_id: sender.id,
      user: sender
    )

    redirect_to notifications_path, notice: "Friend request accepted successfully."
  end

  def accept_note_share(notification)
    note = Note.find(notification.share_id)
    note.shares << current_user
    note.save
    notification.destroy
    redirect_to notifications_path, notice: "Note share request accepted successfully."
  end

  def accept_collection_share(notification)
    collection = Collection.find(notification.share_id)
    collection.shares << current_user
    collection.save

    collection.notes.each do |note|
      note.shares << current_user unless note.share_ids.include?(current_user.id)
      note.save
    end

    notification.destroy
    redirect_to notifications_path, notice: "Collection share request accepted successfully."
  end
end
